db_name = "banka" 
host = "localhost" 
user = "root" 
password = "" 
  
database = dbConnect( "mysql", "dbname="..db_name..";host="..host, user, password ) 
if database then 
    outputDebugString ('basarili') 
else 
    outputDebugString ("basarisiz") 
end

function veriKaydet () 
    local account = getPlayerAccount(source)
	if not isGuestAccount ( account ) then
		local para = getElementData(source, "toplamPara")
		local q =  dbQuery(database,"SELECT * FROM hesap WHERE oyuncuHesap = ?", getAccountName(account)) 
		local poll, rows = dbPoll(q, -1) 
		if not (rows == 0) then 
			dbExec ( database, "UPDATE hesap SET oyuncuPara = ? WHERE oyuncuHesap = ?", para, getAccountName(account)) 
		end
	end
end

function veriYukle ()
    local account = getPlayerAccount(source)
	if not isGuestAccount ( account ) then
		local para = getElementData(source, "toplamPara")
		local q =  dbQuery(database,"SELECT * FROM hesap WHERE oyuncuHesap = ?", getAccountName(account)) 
		local poll, rows = dbPoll(q, -1)
		if(rows == 0) then
			dbExec( database, "INSERT INTO hesap ( oyuncuHesap , oyuncuPara) VALUES ( ?, ?)", getAccountName(account), para )
		end
		local result = dbQuery ( database ,"SELECT * FROM hesap WHERE oyuncuHesap = ?", getAccountName(account)) 
		local poll, rows = dbPoll(result, -1) 
		if rows == 1 then 
        	setElementData ( source, "toplamPara", poll[1]["oyuncuPara"] )
		end
	end
end
addEventHandler ( "onPlayerLogin", getRootElement(), veriYukle ) 
addEventHandler ( "onPlayerQuit", getRootElement(), veriKaydet ) 

function bankaTransfer(thePlayer, command, miktar)
	if not miktar then outputChatBox("miktarı giriniz!", thePlayer, 255,255,255,true) return end
	local bankPara = getElementData(thePlayer, "toplamPara")
	local gamePara = getPlayerMoney(thePlayer)
	local gonderilenPara = tonumber(miktar)
	local account = getPlayerAccount(thePlayer)
	if not isGuestAccount ( account ) then
		if gamePara > 0 then
			takePlayerMoney(thePlayer, gonderilenPara)
			dbExec ( database, "UPDATE hesap SET oyuncuPara = bankPara + gonderilenPara  WHERE oyuncuHesap = ?", getAccountName(account))
			setElementData(thePlayer, "toplamPara", bankPara + gonderilenPara)
			outputChatBox("Bankaya para transferi tamamlandı! #ffaacc"..gonderilenPara.."$", thePlayer, 255,255,255,true)
		end
	end
end
addCommandHandler("transfer", bankaTransfer)
