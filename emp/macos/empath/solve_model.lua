--[[

@version 1.0.0
@author German Molina
@date November 2, 2017

@title Solves the whole model
@brief This script solves all the objectives in the model


]]


auto_solve = false
workplanes = get_workplanes_data()
results_file = argv[1]

-- For all workplanes
for i = 1,#workplanes do
    wp = workplanes[i]
    tasks = wp.tasks

    -- For all tasks in workplane
    for j=1,#tasks do
        task = get_metric(tasks[j])

        -- Assign the workplane to the task
        task["workplane"] = wp.name
        
        
        
        -- Push the task to the Task Manager        
        push_metric(task)

    end        
end


solve(results_file)
