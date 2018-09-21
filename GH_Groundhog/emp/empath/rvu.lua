-- rvu.lua

--Set the Auto Solve to false
auto_solve = false


-- Find a list of views
views = get_views_list()

if #views == 0 then
    error("No views available for RVU")
end

-- Try to find the given view... 
-- default to the first view in model if no view name is given
view_name = argv[1]

-- Ensure that the view exist
if not is_view(view_name) then
    error("View "..view_name.." does not exist")
end

-- Review
review(view_name)
