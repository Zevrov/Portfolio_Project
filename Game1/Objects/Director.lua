Director = GameObject:extend()

function Director:new(area, x, y, opts)
	Director.super.new(self, area, x, y, opts)
    self.difficulty = 1
	
    self.difficulty_to_points = {}
    self.difficulty_to_points[1] = 16
    for i = 2, 1024, 4 do
        self.difficulty_to_points[i] = self.difficulty_to_points[i-1] + 8
        self.difficulty_to_points[i+1] = self.difficulty_to_points[i]
        self.difficulty_to_points[i+2] = math.floor(self.difficulty_to_points[i+1]/1.5)
        self.difficulty_to_points[i+3] = math.floor(self.difficulty_to_points[i+2]*2)
    end
	
	-- Enemies
	self.enemy_to_points = {
        ['Rock'] = 1,
        ['Shooter'] = 2,
    }
	
	self.enemy_spawn_chances = {
        [1] = chanceList({'Rock', 1}),
        [2] = chanceList({'Rock', 8}, {'Shooter', 4}),
        [3] = chanceList({'Rock', 8}, {'Shooter', 8}),
        [4] = chanceList({'Rock', 4}, {'Shooter', 8}),
    }
	
	for i = 5, 1024 do
        self.enemy_spawn_chances[i] = chanceList(
      	    {'Rock', love.math.random(2, 12)}, 
      	    {'Shooter', love.math.random(2, 12)}
    	)
    end
	
	self.timer:every(22, function()
			self.difficulty = self.difficulty + 1
			self:setEnemySpawnsForThisRound()
		end
	)
	
	-- Spawn enemies for Round 1
	self:setEnemySpawnsForThisRound()
	
	-- Resources
	self.resource_spawn_chances = chanceList({'Boost', 28}, {'HP', 14}, {'SP', 58})
	self.timer:every(16, function()
			self.area:addGameObject(self.resource_spawn_chances:next())
		end
	)
	
	-- Attacks
	self.timer:every(30, function()
			local i = 1
			local selectAttackName = {}
			for attackName, _ in pairs(attacks) do
				selectAttackName[i] = attackName
				i = i + 1
			end
			self.area:addGameObject('Attack', 0, 0, {attack = selectAttackName[love.math.random(1, #selectAttackName)]})
		end
	)
	
end

function Director:update(dt)
    Director.super.update(self, dt)
end

function Director:setEnemySpawnsForThisRound()
    local points = self.difficulty_to_points[self.difficulty]

    -- Find enemies
    local enemy_list = {}
    while points > 0 do
        local enemy = self.enemy_spawn_chances[self.difficulty]:next()
        points = points - self.enemy_to_points[enemy]
        table.insert(enemy_list, enemy)
    end
	
    -- Find enemies spawn times
    local enemy_spawn_times = {}
    for i = 1, #enemy_list do 
    	enemy_spawn_times[i] = random(0, self.round_duration) 
    end
    table.sort(enemy_spawn_times, function(a, b) return a < b end)
	
	
    for i = 1, #enemy_spawn_times do
        self.timer:after(enemy_spawn_times[i], function()
            self.area:addGameObject(enemy_list[i])
        end)
    end
end

function Director:destroy()
	Director.super.destroy(self)
end