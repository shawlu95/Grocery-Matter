from sqlalchemy import create_engine
import numpy as np
import pandas as pd

class SQLClient:
    categories = pd.Series(name = 'category_map', 
    	data = {'LOV' : "Love", 
		        'CLO' : "Clothes", 
		        'SAR' : "Sartorial", 
		        'SHO' : "Shoes", 
		        'ACC' : "Accessory", 
		        'STA' : "Stationery", 
		        'PEN' : "Pens", 
		        'HYG' : "Hygiene", 
		        'BOO' : "Book", 
		        'FUR' : "Furniture", 
		        'ELE' : "Electronics", 
		        'SOF' : "Software", 
		        'COM' : "Communication", 
		        'SOC' : "Social", 
		        'TRA' : "Transport", 
		        'ENT' : "Amusement", 
		        'AUT' : "Automobile", 
		        'EDU' : "Education", 
		        'HOU' : "Housing", 
		        'FOO' : "Food", 
		        'INS' : "Insurance",
		        'LEG' : "Legal", 
		        'TAX' : "tax", 
		        'MIS' : "Miscellany",
		        'INV' : "Investment"})
    
    def __init__(self, username, password, port):
        """
        @Parameters
        username: db_user, must have read privilege on grocery dataset
        password: db_user password
        port: port number on localhost (e.g. 7777)
        """

        self.engine = create_engine('mysql+mysqldb://%s:%s@localhost:%i/grocery'%(username, password, port))

    def query(self, sql):
        """
        @parameter
        sql: complete sql command
        @ return
        a panda DataFrame object, indexed by time
        """
        sql = sql.replace('\n', " ").replace("\t", " ")
        df = pd.read_sql_query(sql, self.engine).sort_values("time")
        df = df.set_index("time")
        return df