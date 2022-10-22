#!/usr/bin/env python3

import os
import pandas as pd
from pandas.io.json import json_normalize

os.chdir('/hades/psivakumar/cohorts/macrogen_eh/')

#LI16243
with open('macrogen_jsons_list.txt', 'r') as f:
    json_paths = [json.strip() for json in f]

ex_json = 'eh_res/Sorted_LI16243.bam.json'
json_con = pd.read_json(ex_json)
json_id = json_con.loc[['SampleId', 'Sex'], 'SampleParameters']
json_con = json_con.drop(['SampleId', 'Sex'])

eh_res = pd.DataFrame()
cols = ['AlleleCount', 'LocusId']
for row in json_con.LocusResults:
    res = json_normalize(row)
    eh_res = pd.concat([eh_res, res])
eh_res['SampleId'] = json_id.SampleId
eh_res['Sex'] = json_id.Sex


def get_res_from_json(json_path):
    json_con = pd.read_json(json_path)
    json_id = json_con.loc[['SampleId', 'Sex'], 'SampleParameters']
    json_con = json_con.drop(['SampleId', 'Sex'])
    eh_res = pd.DataFrame()
    for row in json_con.LocusResults:
        res = json_normalize(row)
        eh_res = pd.concat([eh_res, res])
    eh_res['SampleId'] = json_id.SampleId
    eh_res['Sex'] = json_id.Sex
    return eh_res

eh_full = pd.DataFrame()
for json in json_paths:
    res = get_res_from_json(json)
    eh_full = pd.concat([eh_full, res])

eh_full.to_csv('macrogen_eh_results.csv')

eh_melt = pd.melt(eh_full, id_vars=['AlleleCount', 'Coverage', 'LocusId', 'ReadLength', 'SampleId', 'Sex'])

eh_melt[['tmp', 'Tested_ID', 'Measure']] = eh_melt.variable.str.split('\\.', expand=True)

eh_pivot = pd.pivot_table(eh_melt, index=['AlleleCount', 'Coverage', 'LocusId', 'ReadLength', 'SampleId', 'Sex', 'tmp', 'Tested_ID'], columns='Measure', values='value', aggfunc='first')
eh_pivot = eh_pivot.reset_index()

eh_nonan = eh_pivot.dropna()
eh_nonan[['GT1', 'GT2']] = eh_nonan.Genotype.str.split('\\/', expand=True)
eh_nonan[['GT1', 'GT2']] = pd.to_numeric(eh_nonan[['GT1', 'GT2']].stack()).unstack()
eh_nonan['GT_max'] = eh_nonan[['GT1', 'GT2']].max(axis=1)
eh_nonan['GT_mean'] = eh_nonan[['GT1', 'GT2']].mean(axis=1)
eh_nonan = eh_nonan.join(eh_nonan.groupby('VariantId').GT_mean.mean(), on='VariantId', rsuffix='_per_VariantId')
eh_nonan['GT_max_mean_diff'] = eh_nonan['GT_max'] - eh_nonan['GT_mean_per_VariantId']
eh_nonan = eh_nonan.join(eh_nonan.VariantId.value_counts(), on='VariantId', rsuffix='_counts')
eh_nonan = eh_nonan.sort_values(by = 'GT_max_mean_diff', ascending=False)

eh_nonan.to_csv('macrogen_eh_results_cleaned.csv')
