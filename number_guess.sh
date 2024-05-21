#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate random number from 1-1000
SOLUTION=$(( ($RANDOM % 1000) + 1))

# get user info
echo Enter your username:
read USERNAME

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")
if [[ $USER_INFO ]]
then
  # existing user
  IFS="|" read GAMES BEST <<< $USER_INFO
  echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
else
  # new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES=0
fi

# enter guess loop until correct guess
GUESS_COUNT=0
GUESS=5000
while [[ $GUESS -ne $SOLUTION ]]
do
  (( GUESS_COUNT++ ))
  if [[ -z $STARTED ]]
  then
    STARTED='True'
    echo "Guess the secret number between 1 and 1000:"
  elif [[ ! $GUESS =~ [0-9]+ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -lt $SOLUTION ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
  read GUESS
done

# update user info
(( GAMES++ ))
if [[ $GAMES -eq 1 ]]
then
  # case 1: new user, add new entry
  ADDED_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', $GAMES, $GUESS_COUNT);")
else
  if [[ $GUESS_COUNT -lt $BEST ]]
  then
    # case 2: new personal best, update games_played and best_guess
    UPDATED=$($PSQL "UPDATE users SET games_played=$GAMES, best_game=$GUESS_COUNT WHERE username='$USERNAME';")
  else
    # case 3: not a personal best, update games_played
    UPDATED=$($PSQL "UPDATE users SET games_played=$GAMES WHERE username='$USERNAME';")
  fi
fi

# print response message
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SOLUTION. Nice job!"
