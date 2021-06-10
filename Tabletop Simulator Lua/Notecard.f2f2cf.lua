function onPeek()
    print("peeked")
    desc = self.getDescription()
    req = 'spells/' .. desc
    new_desc = desc
    WebRequest.get('https://www.dnd5eapi.co/api/'..req, 
    function (ri) 
        for key, value in pairs(JSON.decode(ri.text)['desc']) do
            new_desc = new_desc .. key .. ':' .. value
        end
        self.setDescription(new_desc)
    end)
end