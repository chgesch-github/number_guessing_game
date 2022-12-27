#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

# Regular expression for integers
re='^[0-9]+$'

# Generate the secret number (between 1 and 1000)
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

# Print secret number
#echo -e "\nSecret number: $SECRET_NUMBER"

echo -e "Enter your username:"
read USERNAME

# Get user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
# If user_id does not exist in database
if [[ -z $USER_ID ]]; then
  # Print welcome message for new user
  echo -e "\nWelcome, $(echo $USERNAME | sed -r 's/^ *| *$//g')! It looks like this is your first time here."
  # Add user to database
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  # Get user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
else
  # If user_id exists in the database, get user information
  GAMES_PLAYED=$($PSQL "SELECT COUNT($USER_ID) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  # Print welcome message for new user
  echo -e "\nWelcome back, $(echo $USERNAME | sed -r 's/^ *| *$//g')! You have played $(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g') games, and your best game took $(echo $BEST_GAME | sed -r 's/^ *| *$//g') guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"

# Create a counter variable for guesses
NUMBER_OF_GUESSES=1

until [[ $GUESS == $SECRET_NUMBER ]]
do
  read GUESS
  # If guess is not an integer, print error message
  until [[ $GUESS =~ $re ]]
  do
    echo -e "\nThat is not an integer, guess again:"
    read GUESS
  done
  
  if [ $SECRET_NUMBER -lt $GUESS ]; then
    # Update the counter variable for guesses
    let NUMBER_OF_GUESSES=$NUMBER_OF_GUESSES+1
    # Print message
    echo -e "\nIt's lower than that, guess again:"
  elif [ $SECRET_NUMBER -gt $GUESS ]; then
    # Update the counter variable for guesses
    let NUMBER_OF_GUESSES=$NUMBER_OF_GUESSES+1
    # Print message
    echo -e "\nIt's higher than that, guess again:"
  else
    # If guess == secret_number, print message
    echo -e "\nYou guessed it in $(echo $NUMBER_OF_GUESSES | sed -r 's/^ *| *$//g') tries. The secret number was $(echo $SECRET_NUMBER | sed -r 's/^ *| *$//g'). Nice job!"

    # ... and update database
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
  fi
done
