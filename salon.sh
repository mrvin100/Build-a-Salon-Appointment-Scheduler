#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
# echo -e "\n$($PSQL "TRUNCATE customers, appointments;")"
MAIN_MENU () {
  echo -e "\nWelcome to My Salon, how can I help you?"
  echo -e "\n1) cut\n2) color\n3) perm\n4) style\n5) trim"

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
  1) SERVICES "cut" ;;
  2) SERVICES "color" ;;
  3) SERVICES "pern" ;;
  4) SERVICES "style" ;;
  5) SERVICES "trim" ;;
  *) MAIN_MENU "I could not find that service. What would you like today?";;
  esac
}

APPOINTMENT () {
  # appointment function to add datas
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  # get service id
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name='$SERVICE_NAME' LIMIT 1")
  # check if service id exist in services table
  if [[ -n $SERVICE_ID ]]
  then
    # check if customer phone exit in table to know if i cant insert it
    if [[ -z $SELECT_CUSTOMER_PHONE ]]
    then
      # insert customer infos
      INSERT_INTO_CUSTOMERS=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      echo $INSERT_INTO_CUSTOMERS
    fi
    # get customer id
    CUSTOMER_ID_TO_FORMATED=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME' AND phone='$CUSTOMER_PHONE' LIMIT 1")
    CUSTOMER_ID=$(echo $CUSTOMER_ID_TO_FORMATED | sed -E 's/^ +| +$//')
    echo customer id : .$CUSTOMER_ID. customer phone : .$CUSTOMER_PHONE. customer name : .$CUSTOMER_NAME.
    # check if customer insertion is succesfull
    if [[ -n $CUSTOMER_ID ]]
    then
      # insert appointments infos
      INSERT_INTO_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

SERVICES () {
  SERVICE_NAME=$1
  echo $SERVICE_NAME service is open

  # ask phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # select customer phone
  SELECT_CUSTOMER_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE' LIMIT 1")

  # check if cut service is choose

  if [[ -z $SELECT_CUSTOMER_PHONE ]]
  then
    if [[ -n $SERVICE_NAME ]]
    then
      # cut service is open
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # add appointment
      APPOINTMENT
    fi
  else
    # get customer name
    CUSTOMER_NAME_TO_FORMATTED=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE' LIMIT 1")
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME_TO_FORMATTED | sed -E 's/^ +| +$//')
    echo customer name : .$CUSTOMER_NAME_TO_FORMATTED. name formated : .$CUSTOMER_NAME.
    if [[ -n $CUSTOMER_NAME ]]
    then
      echo add appointment
      # add appointment
      APPOINTMENT
    fi
  fi
}

MAIN_MENU