function state_list = load_state_list()

state_file =  'state_hosp_data_old/list_of_states.csv';

states = readtable(state_file);
state_list = states.(1);
    
end
