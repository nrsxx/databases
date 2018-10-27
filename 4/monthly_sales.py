#!/usr/bin/python

import cx_Oracle as cx
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

ip = '127.0.0.1'
port = 1521
SID = 'XE'
dsn_tns = cx.makedsn(ip, port, SID)

conn = cx.connect('BOOKS_ADMIN', 'oracle', dsn_tns)
cur = conn.cursor()

sales = []

for date in daterange(start, end):
    cur.execute("""SELECT PublisherName, Sales FROM \"MonthlySales\" WHERE \"Date\" = TO_DATE('{}', 'yyyy/mm/dd')""".format(str(date).replace('-', '/')))
    rows = cur.fetchall()
    monthly_sales = dict([(row[0], row[1]) for row in rows])
    sales.append(monthly_sales)

cur.close()
conn.close()

result = pd.DataFrame(sales, daterange(start, end)).T
print(result)
