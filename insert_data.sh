#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams")

# Adiciona equipes únicas à tabela teams
cat games.csv | tail -n +2 | while IFS="," read YEAR ROUND WINNER OPPONENT WINGOALS OPPGOALS
do
  # Adiciona o vencedor se ainda não estiver na tabela e não for "winner"
  if [[ $WINNER != "winner" ]]; then
    $PSQL "INSERT INTO teams (name) SELECT '$WINNER' WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name='$WINNER')"
  fi
  
  # Adiciona o oponente se ainda não estiver na tabela e não for "opponent"
  if [[ $OPPONENT != "opponent" ]]; then
    $PSQL "INSERT INTO teams (name) SELECT '$OPPONENT' WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name='$OPPONENT')"
  fi
  
  # Obter IDs das equipes
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  
  # Inserir dados na tabela games
  $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINGOALS', '$OPPGOALS')"
done

echo "Equipes únicas adicionadas à tabela 'teams' e dados inseridos na tabela 'games'."
