#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ Puki's Salon ~~~~"

MAIN_MENU() {
 echo -e "\n$1\n"
 echo "$($PSQL "SELECT * FROM services")" | while read SID BAR NAME
 do
  echo "$SID) $NAME"
 done
 read SERVICE_ID_SELECTED
 if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]+$ ]]
 then
  MAIN_MENU "I Could not find that service, what would you like to do today?"
 else
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone LIKE '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that number, what's your name?"
    read CUSTOMER_NAME
    CUSTOMER_INSERTED=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone LIKE '$CUSTOMER_PHONE'")
  fi
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
  echo -e "\nWhat time would you like to do your $($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed 's/^ *//'), $CUSTOMER_NAME?"
  read SERVICE_TIME
  APPOINTMENT_INSERTED=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed 's/^ *//') at $SERVICE_TIME,$CUSTOMER_NAME."
 fi
}

MAIN_MENU "Welcome to puki salon, how can i help you?"
