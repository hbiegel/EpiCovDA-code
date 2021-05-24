function state_list = load_state_list()

state_file =  'list_of_states.csv';

states = readtable(state_file);
state_list = states.(1);
    
end
