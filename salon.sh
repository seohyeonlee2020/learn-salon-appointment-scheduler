#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ RAINBOW SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

SERVICE_LIST=$($PSQL "SELECT * FROM services")
echo "$SERVICE_LIST" | while read ID BAR NAME
do
  if [[ $ID =~ ^[0-9]+$ ]]
  then
    echo "$ID) $NAME"
  fi
done
#read input
read SERVICE_ID_SELECTED
echo "id selected: $SERVICE_ID_SELECTED"
#get input id
SERVICE_COUNT=$(echo $($PSQL "SELECT COUNT(*) FROM services") | sed -E 's/^ | $//g')
echo "service count: $SERVICE_COUNT"
#if not found
if ([[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ $SERVICE_ID_SELECTED > $SERVICE_COUNT ]] || [[ $SERVICE_ID_SELECTED == 0 ]])
then
#error message and show same options
MAIN_MENU "I could not find that service. What would you like today?"
else
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
echo $CUSTOMER_PHONE
#get customer id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
echo $CUSTOMER_ID
#if not found
  if [[ -z $CUSTOMER_ID ]]
  #ask for name
  then
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERTED_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  echo "customer inserted: $INSERTED_CUSTOMER"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  else
  #get customer name from pre-existing id
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  #trim customer name
  CUSTOMER_NAME_TRIMMED=$(echo $CUSTOMER_NAME | sed -E 's/^ | $//g')
  SERVICE_NAME=$($PSQL "SELECT DISTINCT(name) FROM services LEFT JOIN appointments USING (service_id) WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME_TRIMMED=$(echo $SERVICE_NAME | sed -E 's/^ | $//g')

  echo "What time would you like your $SERVICE_NAME_TRIMMED, $CUSTOMER_NAME_TRIMMED?"
  read SERVICE_TIME
  INSERTED_APPT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
  
  echo "I have put you down for a $SERVICE_NAME_TRIMMED at $SERVICE_TIME, $CUSTOMER_NAME_TRIMMED."
fi
}

MAIN_MENU