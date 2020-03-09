function [table_overall_a,table_overall_b_Case, table_overall_b_Death] = covid19data()
    warning("off")
    a_tableinfo=webread('https://spreadsheets.google.com/feeds/list/1lwnfa-GlNRykWBL5y7tWpLxDoCfs8BvzWxFjeOZ1YJk/1/public/values?alt=json');
    b_chartinfo=webread("https://spreadsheets.google.com/feeds/list/1NbedmkD3VpoP6Poc_1Xl-ElroXi08X5UyNBeyI1ts28/1/public/values?alt=json");
    % a_tableinfo
    for i = 1:1:size(a_tableinfo.feed.entry,1)
        Country_a(i) = string(a_tableinfo.feed.entry(i).gsx_country.x_t);
        Updated_time_a(i) = string(a_tableinfo.feed.entry(i).updated.x_t);
        Confirmed_Case_a(i) = str2double(string(a_tableinfo.feed.entry(i).gsx_confirmedcases.x_t));
        Death_a(i) = str2double(string(a_tableinfo.feed.entry(i).gsx_reporteddeaths.x_t));
    end
    table_overall_a = table(Country_a',Updated_time_a',Confirmed_Case_a',Death_a');
    table_overall_a.Properties.VariableNames = {'Country' 'Updated' 'Case' 'Death'};

    %b_chartinfo
    % a_tableinfo
    for i = 1:1:size(b_chartinfo.feed.entry,1)
        Country_b(i) = string(b_chartinfo.feed.entry(i).gsx_place.x_t);
        Updated_time_b(i) = string(b_chartinfo.feed.entry(i).gsx_date.x_t);
        Confirmed_Case_b(i) = str2double(string(b_chartinfo.feed.entry(i).gsx_confirmedcases.x_t));
        Death_b(i) = str2double(string(b_chartinfo.feed.entry(i).gsx_reporteddeaths.x_t));
    end
    
    table_overall_b = table(Country_b',Updated_time_b',Confirmed_Case_b',Death_b');
    table_overall_b.Properties.VariableNames = {'Country' 'Updated' 'Case' 'Death'};
    
    %delete the row if updated time is unknown
        table_overall_b(strcmp(table_overall_b.Updated,""),:)=[];
    
    %Split into 2 table Case & Death associated with time
    table_overall_b_Case=unstack(table_overall_b,"Case","Country");
    table_overall_b_Case.Death =[];
    table_overall_b_Death=unstack(table_overall_b,"Death","Country");
    table_overall_b_Death.Case =[];
    
    % Convert string to datetime
    table_overall_b_Case.Updated = datetime(table_overall_b_Case.Updated,'InputFormat','MMM dd');
    table_overall_b_Death.Updated = datetime(table_overall_b_Death.Updated,'InputFormat','MMM dd');
    
    % Get the max value for same date (Some day reported the value multiple
    % time)
    variableName = table_overall_b_Case.Properties.VariableNames;
    table_overall_b_Case=varfun(@max,table_overall_b_Case,'GroupingVariable','Updated');
    table_overall_b_Case.GroupCount =[];
    table_overall_b_Case.Properties.VariableNames = variableName;
    table_overall_b_Death=varfun(@max,table_overall_b_Death,'GroupingVariable','Updated');
    table_overall_b_Death.GroupCount = [];
    table_overall_b_Death.Properties.VariableNames = variableName;
    
    % Fill Missing Data
    % fill missing data with previous value, if don't have previous value, fill
    % it with zero
    table_overall_b_Case = fillmissing(table_overall_b_Case,"previous");
    table_overall_b_Case = fillmissing(table_overall_b_Case,"constant",0,'DataVariables',@isnumeric);
    table_overall_b_Death = fillmissing(table_overall_b_Death,"previous");
    table_overall_b_Death = fillmissing(table_overall_b_Death,"constant",0,'DataVariables',@isnumeric);
end
