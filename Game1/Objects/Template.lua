NewGameObject = GameObject:extend()

function NewGameObject:new(area, x, y, opts)
    NewGameObject.super.new(self, area, x, y, opts)
end

function NewGameObject:update(dt)
    NewGameObject.super.update(self, dt)
end

function NewGameObject:draw()

end

function NewGameObject:destroy()
    NewGameObject.super.destroy(self)
end
