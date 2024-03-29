local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local clockInitial = os.clock()

Knit.AddServices(script.Parent.Services)

Knit.Start():andThen(function()
    print(("[Knit Server]: Framework initialized [%sms]"):format(os.clock() - clockInitial))
end):catch(warn)