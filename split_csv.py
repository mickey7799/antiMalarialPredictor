

filename = r'input_ID.csv'
csvfile = open( filename, 'r').readlines()
lines_in_csvfile = len(csvfile)
total_subcsvfile = 100
lines_in_seperate_csvfile = round( (lines_in_csvfile  - 1 ) / total_subcsvfile )
print(" all lines in " + filename + " is " + str( lines_in_csvfile ))
print("split data into subfile with lines : " + str( lines_in_seperate_csvfile))
header = csvfile[0] # store header

for file_number in range(0, total_subcsvfile ):
    split_file = open( "input_ID."+ str(file_number) + '.csv', 'w+')
    split_file.writelines(header) # prepend header
    start_line_index = 1 + file_number * lines_in_seperate_csvfile
    end_line_index = start_line_index + lines_in_seperate_csvfile
    split_file.writelines( csvfile[ start_line_index:end_line_index]) # write lines
   