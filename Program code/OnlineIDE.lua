local IDE = {}

IDE.rnrn = 0
IDE.Status = 0
IDE.DataToGet = 0
IDE.method = ""
IDE.url = ""
IDE.vars = ""

function EditorReceive(sck, payload, aceEnabled)

	local AceEnabled = aceEnabled == nil and true or aceEnabled

	if IDE.Status == 0 then
        _, _, IDE.method, IDE.url, IDE.vars = string.find(payload, "([A-Z]+) /([^?]*)%??(.*) HTTP")
        -- print("IDE.method, IDE.url, IDE.vars: ", IDE.method, IDE.url, IDE.vars)
    end
    
    if IDE.method == "POST" then
    
        if IDE.Status == 0 then
            -- print("IDE.Status", IDE.Status)
            _, _, IDE.DataToGet, payload = string.find(payload, "Content%-Length: (%d+)(.+)")
            if IDE.DataToGet then
                IDE.DataToGet = tonumber(IDE.DataToGet)
                -- print("IDE.DataToGet = "..IDE.DataToGet)
                IDE.rnrn = 1
                IDE.Status = 1                
            else
                print("bad length")
            end
        end
        
        -- find /r/n/r/n
        if IDE.Status == 1 then
            -- print("IDE.Status", IDE.Status)
            local payloadlen = string.len(payload)
            local mark = "\r\n\r\n"
            local i
            for i=1, payloadlen do                
                if string.byte(mark, IDE.rnrn) == string.byte(payload, i) then
                    IDE.rnrn = IDE.rnrn + 1
                    if IDE.rnrn == 5 then
                        payload = string.sub(payload, i+1, payloadlen)
                        file.open(IDE.url, "w")
                        file.close() 
                        IDE.Status = 2
                        break
                    end
                else
                    IDE.rnrn = 1
                end
            end    
            if IDE.Status == 1 then
                return 
            end
        end       
    
        if IDE.Status == 2 then
            -- print("IDE.Status", IDE.Status)
            if payload then
                IDE.DataToGet = IDE.DataToGet - string.len(payload)
                --print("IDE.DataToGet:", IDE.DataToGet, "payload len:", string.len(payload))
                file.open(IDE.url, "a+")
                file.write(payload)            
                file.close() 
            else
                sck:send("HTTP/1.1 200 OK\r\n\r\nERROR")
                IDE.Status = 0
            end

            if IDE.DataToGet == 0 then
                sck:send("HTTP/1.1 200 OK\r\n\r\nOK")
                IDE.Status = 0
            end
        end
        
        return
    end
    -- end of POST IDE.method handling
    
    IDE.DataToGet = -1
    
    if IDE.url == "favicon.ico" then
        -- print("favicon.ico handler sends 404")
        sck:send("HTTP/1.1 404 file not found")
        return
    end    

    local sen = "HTTP/1.1 200 OK\r\n\r\n"
    
    -- it wants a file in particular
    if IDE.url ~= "" and IDE.vars == "" then
        IDE.DataToGet = 0
        sck:send(sen)
        return
    end

    sen = sen .. "<html><body><h1><a href='/'>NodeMCU IDE</a></h1>"
    
    if IDE.vars == "edit" then
        if AceEnabled then
            local mode = 'ace/mode/'
            if IDE.url:match(".css") then mode = mode .. 'css'
            elseif IDE.url:match(".html") then mode = mode .. 'html'
            elseif IDE.url:match(".json") then mode = mode .. 'json'
            elseif IDE.url:match(".js") then mode = mode .. 'javascript'
            else mode = mode .. 'lua'
            end
            sen = sen .. "<style type='text/css'>#editor{width: 100%; height: 80%}</style><div id='editor'></div><script src='//rawgit.com/ajaxorg/ace-builds/master/src-min-noconflict/ace.js'></script>"
                .. "<script>var e=ace.edit('editor');e.setTheme('ace/theme/monokai');e.getSession().setMode('"..mode.."');function getSource(){return e.getValue();};function setSource(s){e.setValue(s);}</script>"
        else
            sen = sen .. "<textarea name=t cols=79 rows=17></textarea></br>"
                .. "<script>function getSource() {return document.getElementsByName('t')[0].value;};function setSource(s) {document.getElementsByName('t')[0].value = s;};</script>"
        end
        sen = sen .. "<script>function tag(c){document.getElementsByTagName('w')[0].innerHTML=c};var x=new XMLHttpRequest();x.onreadystatechange=function(){if(x.readyState==4) setSource(x.responseText);};"
        .. "x.open('GET',location.pathname);x.send()</script><button onclick=\"tag('Saving, wait!');x.open('POST',location.pathname);x.onreadystatechange=function(){console.log(x.readyState);"
        .. "if(x.readyState==4) tag(x.responseText);};x.send(new Blob([getSource()],{type:'text/plain'}));\">Save</button> <a href='?run'>run</a> <w></w>"

    elseif IDE.vars == "run" then
        sen = sen .. "<verbatim>"

        function s_output(str) sen = sen .. str end
        node.output(s_output, 0) -- re-direct output to function s_output.

        local st, result = pcall(dofile, IDE.url)

        -- delay the output capture by 1000 milliseconds to give some time to the user routine in pcall()
        tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function() 
            node.output(nil)
            if result then
                local outp = tostring(result):sub(1,1300) -- to fit in one send() packet
                result = nil
                sen = sen .. "<br>Result of the run: " .. outp .. "<br>"
            end
            sen = sen .. "</verbatim></body></html>"
            sck:send(sen)
        end)

        return

    elseif IDE.vars == "compile" then
        collectgarbage()
        node.compile(IDE.url)
        IDE.url = ""

    elseif IDE.vars == "delete" then
        file.remove(IDE.url)
        IDE.url = ""

    elseif IDE.vars == "restart" then
        node.restart()
        return

    end

    local message = {}
    message[#message + 1] = sen
    sen = nil
    if IDE.url == "" then
        local l = file.list();
        message[#message + 1] = "<table border=1 cellpadding=3><tr><th>Name</th><th>Size</th><th>Edit</th><th>Compile</th><th>Delete</th></tr>"
        for k,v in pairs(l) do
            local line = "<tr><td><a href='" ..k.. "'>" ..k.. "</a></td><td>" ..v.. "</td><td>"
            local editable = k:sub(-4, -1) == ".lua" or k:sub(-4, -1) == ".css" or k:sub(-5, -1) == ".html" or k:sub(-5, -1) == ".json"
            if editable then
                line = line .. "<a href='" ..k.. "?edit'>edit</a>"
            end
            line = line .. "</td><td>"
            if k:sub(-4, -1) == ".lua" then
                line = line .. "<a href='" ..k.. "?compile'>compile</a>"
            end
            line = line .. "</td><td><a href='" ..k.. "?delete'>delete</a></td></tr>"
            message[#message + 1] = line
        end
        message[#message + 1] = "</table><a href='#' onclick='v=prompt(\"Filename\");if (v!=null) { this.href=\"/\"+v+\"?edit\"; return true;} else return false;'>Create new</a> &nbsp; &nbsp; "
    message[#message + 1] = "<a href='#' onclick='var x=new XMLHttpRequest();x.open(\"GET\",\"/?restart\");x.send();setTimeout(function(){location.href=\"/\"},5000);this.innerText=\"Please wait\";return false'>Restart</a>"
    end
    message[#message + 1] = "</body></html>"

    local function send_table(sk)
        if #message > 0 then
            sk:send(table.remove(message, 1))
        else
            sk:close()
            message = nil
        end
    end
    sck:on("sent", send_table)
    send_table(sck)
end
IDE.receive = EditorReceive

function EditorSent(sck)
    if (IDE.DataToGet >= 0 and IDE.method == "GET") then
        if (file.open(IDE.url, "r")) then
            file.seek("set", IDE.DataToGet)
            local chunkSize = 512
            local line = file.read(chunkSize)
            file.close()
            if (line) then
                sck:send(line)
                IDE.DataToGet = IDE.DataToGet + chunkSize
                if (string.len(line) == chunkSize) then 
                	return
                end
            end
        end        
    end

	sck:close()
	sck = nil
end
IDE.sent = EditorSent

print ("OnlineIDE script loaded")

return IDE
