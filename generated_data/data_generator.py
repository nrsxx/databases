#!/usr/bin/python

import pandas as pd
import numpy as np
import scipy.stats as sps
import names
import random_words
import sys
from faker import Factory
import random
from datetime import date
import calendar


fake = Factory.create()
nick = random_words.RandomNicknames()

author_id = 1
book_id = 1
publisher_id = 1
client_id = 1
order_id = 1
edition_id = 1


class Book:
    def __init__(self, name):
        global book_id
        self.name = name
        self.short_name = None
        if len(name) > 4:
            self.short_name = name[:4]
        self.id = book_id
        book_id += 1


class Author:
    def __init__(self, first_name, middle_name, last_name):
        global author_id
        self.first_name = first_name
        self.middle_name = middle_name
        self.last_name = last_name
        self.books = []
        self.id = author_id
        author_id += 1

    def generate_books(self):
        book_number = sps.poisson.rvs(5)
        for i in range(book_number):
            self.books.append(Book(random_words.RandomWords().random_word()))


class Publisher:
    def __init__(self, name, city):
        global publisher_id
        self.name = name
        self.city = city
        self.id = publisher_id
        publisher_id += 1


class Client:
    def __init__(self, login, name):
        global client_id
        self.login = login
        self.name = name
        self.id = client_id
        client_id += 1


class Order:
    def __init__(self, cliend_id, opened_date, closed_date):
        global order_id
        self.client_id = cliend_id;
        self.opened_date = opened_date
        self.closed_date = closed_date
        self.id = order_id
        order_id += 1


class Edition:
    def __init__(self, book_id, publisher_id, publisher_year, pages_count):
        global edition_id
        self.book_id = book_id
        self.publisher_id = publisher_id
        self.publisher_year = publisher_year
        self.pages_count = pages_count
        self.id = edition_id
        edition_id += 1


class OrderItems:
    def __init__(self, order_id, edition_id, client_id, count):
        self.order_id = order_id
        self.edition_id = edition_id
        self.client_id = client_id
        self.count = count



author_number = int(sys.argv[1])

authors = [Author(names.get_first_name(), nick.random_nick(gender='u'), names.get_last_name())
           for x in range(author_number)]

authors_data = pd.DataFrame({'ID':[x.id for x in authors],
                        'FirstName':[x.first_name for x in authors],
                        'MiddleName':[x.middle_name for x in authors],
                        'LastName':[x.last_name for x in authors]})
authors_data = authors_data[['ID', 'FirstName', 'MiddleName', 'LastName']]
authors_data.to_csv('author.csv', index=False)


publisher_number = int(sys.argv[2])

publisher_names = []
while len(publisher_names) != publisher_number:
    publisher_names = publisher_names + [fake.company() for x in range(publisher_number - len(publisher_names))]
    publisher_names = list(set(publisher_names))

publishers = [Publisher(name, fake.city()) for name in publisher_names]
publishers_data = pd.DataFrame({'ID':[x.id for x in publishers],
                           'Name':[x.name for x in publishers],
                           'City':[x.city for x in publishers]})
publishers_data = publishers_data[['ID', 'Name', 'City']]
publishers_data.to_csv('publisher.csv', index=False)


client_number = int(sys.argv[3])
clients = [Client(nick.random_nick(gender='u'), names.get_full_name()) for x in range(client_number)]

clients_data = pd.DataFrame({'ID':[x.id for x in clients],
                             'Login':[x.login for x in clients],
                             'Name':[x.name for x in clients]})
clients_data = clients_data[['ID', 'Login', 'Name']]
clients_data.to_csv('client.csv', index=False)


for author in authors:
    author.generate_books()
books_data = pd.DataFrame({'ID':sum([[x.id for x in author.books] for author in authors], []),
                           'Name':sum([[x.name for x in author.books] for author in authors], []),
                           'ShortName':sum([[x.short_name for x in author.books] for author in authors], [])})
books_data = books_data[['ID', 'Name', 'ShortName']]
books_data.to_csv('book.csv', index=False)

books_authors_data = pd.DataFrame({'BookID':sum([[x.id for x in author.books] for author in authors], []),
                                   'AuthorID':sum([[author.id for x in author.books] for author in authors], [])})
books_authors_data = books_authors_data[['BookID', 'AuthorID']]
books_authors_data.to_csv('book_authors.csv', index=False)


editions = sum([[Edition(book.id, random.choice(publishers).id, random.randrange(1800, 2017), sps.poisson.rvs(random.choice([100, 500, 1000]))) for book in author.books]
                for author in authors], [])
editions_data = pd.DataFrame({'ID':[x.id for x in editions],
                              'BookID':[x.book_id for x in editions],
                              'PublisherID':[x.publisher_id for x in editions],
                              'PublishYear':[x.publisher_year for x in editions],
                              'PagesCount':[x.pages_count for x in editions]})
editions_data = editions_data[['ID', 'BookID', 'PublisherID', 'PublishYear', 'PagesCount']]
editions_data.to_csv('edition.csv', index=False)


order_number = int(sys.argv[4])
orders = []

for i in range(order_number):
    year1 = random.randrange(1960, 2017)
    month1 = random.randrange(1, 13)
    day1 = random.randrange(1, calendar.monthrange(year1, month1)[1] + 1)

    year2 = random.randrange(year1, 2017)
    month2 = random.randrange(1, 13)
    if year1 == year2:
        month2 = random.randrange(month1, 13)
    day2 = random.randrange(1, calendar.monthrange(year2, month2)[1] + 1)
    if year1 == year2 and month1 == month2:
        day2 = random.randrange(day1, calendar.monthrange(year2, month2)[1] + 1)

    client_id = random.choice(clients).id;

    opened_date = date(year1,  month1, day1)
    closed_date = date(year2, month2, day2)

    orders.append(Order(client_id, opened_date, closed_date))

orders_data = pd.DataFrame({'ID':[x.id for x in orders],
                            'ClientID':[x.client_id for x in orders],
                            'OpenedDate':[x.opened_date for x in orders],
                            'ClosedDate':[x.closed_date for x in orders]})
orders_data = orders_data[['ID', 'ClientID', 'OpenedDate', 'ClosedDate']]
orders_data.to_csv('order.csv', index=False)


order_items_data = pd.DataFrame({'OrderID':[x.id for x in orders],
                                 'EditionID':[random.choice(editions).id for x in orders],
                                 'Count':[sps.poisson.rvs(3) for x in orders]})
order_items_data = order_items_data[['OrderID', 'EditionID', 'Count']]
order_items_data.to_csv('order_items.csv', index=False)
