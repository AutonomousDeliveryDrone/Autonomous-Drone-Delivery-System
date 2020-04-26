import os
import time
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import random
from flask import Flask, request

def connectToDB():
    cred = credentials.Certificate('/Users/michaelpeng/Downloads/drone-delivery-credentials.json')
    firebase_admin.initialize_app(cred, {
         'databaseURL' : 'https://dronedeliveryecommerce.firebaseio.com/'
    })
    return db.reference()

dbRoot = connectToDB()
companies = dbRoot.child('Orders/Companies')
pendingOrders = dbRoot.child('Orders/Pending')

def retrieveOrderDoc(orderNum):
    return pendingOrders.child(str(orderNum))

def updateCompanyOrder(orderNum, coord1, coord2, index):
    orderRef = retrieveOrderDoc(orderNum)
    print("Sending coords " + str(coord1) + " " + str(coord2))
    orderRef.update({'xCoord': coord1, 'yCoord': coord2, 'r': index})


def pushOrder(orderNum, companyId):
    pendingOrders.child(str(orderNum)).set({'companyId': companyId, 'droneId': 'NO_ID'})

def sendInfo(line):
    print("Sending line " + line)
    arr = line.split()
    updateCompanyOrder(int(arr[0]), float(arr[1]), float(arr[2]))
    
def delete_line(original_file, line_number):
    """ Delete a line from a file at the given line number """
    is_skipped = False
    current_index = 0
    dummy_file = original_file + '.bak'
    # Open original file in read only mode and dummy file in write mode
    with open(original_file, 'r') as read_obj, open(dummy_file, 'w') as write_obj:
        for line in read_obj:
            if current_index != line_number:
                write_obj.write(line)
            else:
                is_skipped = True
            current_index += 1
 
    # If any line is skipped then rename dummy file as original file
    if is_skipped:
        os.remove(original_file)
        os.rename(dummy_file, original_file)
    else:
        os.remove(dummy_file)

"""
def main():    
    while (True):
        with open("coordinates.txt", "r") as f:
            line = f.readline()
            time.sleep(5)
            if line != "":
                sendInfo(line)
            f.close()
        delete_line("coordinates.txt", 0) 

main()
"""

def generator(org_x, org_y, dest_x, dest_y, r = 20):
    i = 0
    loc_x = org_x
    loc_y = org_y
    delta_x = (dest_x - org_x)/r
    delta_y = (dest_y - org_y)/r
    while loc_x < dest_x and loc_y < dest_y:
        yield (loc_x, loc_y, i)
        loc_x += delta_x + random.random()*0.000005
        loc_y += delta_y + random.random()*0.000005
        i+=1

g = generator(37.304852, -122.029282, 37.305540, -122.029070, r = 10)
while True:
    try:
        time.sleep(3)
        loc_x, loc_y, i = next(g)
        updateCompanyOrder(47, loc_x, loc_y, i)
    except:
        break

app = Flask(__name__)

if __name__ == "__main__":
    app.run()
