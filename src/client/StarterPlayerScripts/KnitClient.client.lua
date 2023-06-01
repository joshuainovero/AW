local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local clockInitial = os.clock()

Knit.Start():andThen(function()
    print(("[Knit Client]: Framework initialized [%sms]"):format(os.clock() - clockInitial))
end):catch(warn)