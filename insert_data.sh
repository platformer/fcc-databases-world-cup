#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "truncate table games, teams")

DATA_FILE="games.csv"

{
  read
  while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
  do
    WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")

    if [[ -z $WINNER_ID ]]
    then
      INSERT_RESULT=$($PSQL "insert into teams(name) values('$WINNER')")

      if [[ $INSERT_RESULT == "INSERT 0 1" ]]
      then
        WINNER_ID=$($PSQL "select team_id from teams where name='$WINNER'")
        echo "Inserted team: $WINNER"
      else
        continue
      fi
    fi

    OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")

    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_RESULT=$($PSQL "insert into teams(name) values('$OPPONENT')")

      if [[ $INSERT_RESULT == "INSERT 0 1" ]]
      then
        OPPONENT_ID=$($PSQL "select team_id from teams where name='$OPPONENT'")
        echo "Inserted team: $OPPONENT"
      else
        continue
      fi
    fi

    INSERT_RESULT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")

    if [[ $INSERT_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted game: $YEAR, $ROUND, $WINNER v. $OPPONENT"
    fi
  done
} < $DATA_FILE
