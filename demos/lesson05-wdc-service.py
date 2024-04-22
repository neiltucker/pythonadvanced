from flask import Flask, jsonify, request
from flask_restful import Resource, Api
import mysql.connector
from datetime import date
from decimal import *
from flask_httpauth import HTTPBasicAuth

# create the flask app and API object.
app = Flask(__name__)
api = Api(app)
auth = HTTPBasicAuth()

user_data = {
    "client":"Password1234"
}

class Products(Resource):
    """Get product data from wwproducts database."""

    @auth.verify_password
    def verify(username, password):
        if not (username and password):
            return False
        return user_data.get(username) == password
    @auth.login_required

    def get(self):
        self.mydb = mysql.connector.connect(
            host="localhost",
            user="root",
            password="password",
            database="wwproducts")

        self.mycursor = self.mydb.cursor()

        self.products = []
        self.mycursor.execute("SELECT product, price FROM products")
        self.row = self.mycursor.fetchone()
        while self.row is not None:
            self.products.append(self.row[0])
            self.row = self.mycursor.fetchone()
        self.mydb.close()
        return jsonify({'products': self.products})


class Prices(Resource):
    """Get price data from wwproducts database."""

    def get(self):
        self.mydb = mysql.connector.connect(
            host="localhost",
            user="root",
            password="password",
            database="wwproducts")

        self.mycursor = self.mydb.cursor()

        self.prices = []
        self.mycursor.execute("SELECT product, price FROM products")
        self.row = self.mycursor.fetchone()
        while self.row is not None:
            self.prices.append(float(self.row[1]))
            self.row = self.mycursor.fetchone()
        self.mydb.close()
        return jsonify({'prices': self.prices})


class Submit(Resource):
    """Insert order data to wworders database."""

    def post(self):
        postship = request.json.get('ship')
        posttotal = Decimal(request.json.get('total'))

        self.mydb = mysql.connector.connect(
            host="localhost",
            user="root",
            password="password",
            database="wworders")

        self.mycursor = self.mydb.cursor()

        sql = ("INSERT INTO ordersummary "
               "(orderdate, shipmethod, totalprice) "
               "VALUES (%s, %s, %s)")
        val = (date.today(), postship, posttotal)

        self.mycursor.execute(sql, val)
        self.mydb.commit()
        self.mydb.close()

        return jsonify(self.mycursor.lastrowid)


# add the defined resources along with their corresponding urls.
api.add_resource(Products, '/products')
api.add_resource(Prices, '/prices')
api.add_resource(Submit, '/submit')

app.run()
