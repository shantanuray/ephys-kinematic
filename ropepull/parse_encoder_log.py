from os.path import join, split, splitext
from glob import glob
import pandas as pd
import re


fpath = join('/mnle/data/AYESHA_THANAWALLA/U19/','CFL*','*_data')
file_pattern = 'CFL*CoolTerm*.txt'
file_list = glob(join(fpath,file_pattern))

columns = ['TIME (ms)', 'BNC1', 'BNC2', 'ABORT']
regex_columns = ['TIME \(ms\): *(\d+)\n', 'BNC1: *(\d+)\n', 'BNC2: *(\d+)\n', '(ABORT)\n']
regex_columns = [re.compile(x) for x in regex_columns]


for filename in file_list:
    trial_count = -1
    df = pd.DataFrame(columns=columns)
    save_filename_base, save_filename = split(filename)
    save_filename,_ = splitext(save_filename)
    save_filename = save_filename + '.csv'
    with open(filename, 'r') as fp:
        for line_no, line in enumerate(fp):
            if columns[0] in line:
                print(line)
                trial_count += 1
                df.loc[trial_count, columns[0]] = int(regex_columns[0].search(line).group(1))
            for idx, col in enumerate(columns[1:-1]):
                if col in line:
                    print(line)
                    df.loc[trial_count, col] = int(regex_columns[idx+1].search(line).group(1))
            if columns[-1] in line:
                print(line)
                df.loc[trial_count, columns[-1]] = 'True'
        df.to_csv(join(save_filename_base, save_filename))
        print(f'Saving encoder info to {join(save_filename_base, save_filename)}')
