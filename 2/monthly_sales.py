#!/usr/bin/python

import psycopg2 as ps
import datetime
import sys
import pandas as pd

start = sys.argv[1].split('-')
end = sys.argv[2].split('-')

start = datetime.date(int(start[0]), int(start[1]), 1)
end = datetime.date(int(end[0]), int(end[1]), 1)

if end < start:
    raise ValueError("start date must be less than end date")

def daterange(start_date, end_date):
    for year in range(start_date.year, end_date.year + 1):
        if year == start_date.year:
            month_start = start_date.month
        else:
            month_start = 1
        if year == end_date.year:
            month_end = end_date.month + 1
        else:
            month_end = 13
        for month in range(month_start, month_end):
            yield datetime.date(year, month, 1)


conn = ps.connect("dbname='postgres' user='randan' host='localhost'")
cur = conn.cursor()

sales = []

for date in daterange(start, end):
    cur.execute("""SELECT PublisherName, Sales FROM \"MonthlySales\" WHERE Date = to_date('{}', 'YYYY MM DD')""".format(date))
    rows = cur.fetchall()
    monthly_sales = dict([(row[0], row[1]) for row in rows])
    sales.append(monthly_sales)

cur.close()
conn.close()

result = pd.DataFrame(sales, daterange(start, end)).T
print(result)
