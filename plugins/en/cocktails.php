<?php
  //Usual jamesoff.net headers etc
  include "../../include/_layout.phtml";
  include "../../include/_database.phtml";

  $layout = new PlainLayout();

  $layout->options["title"] = "[ JamesOff.net [ Randomness ]";
  $layout->options["stylesheet"] = "../../include/newstyles.css";

  $layout->startPage();
  $layout->startLayout();
  //Done


  /* Random Recipe Generator v1.1
   * (c) James Seward 2002
   */

  //Seed with microseconds
  list($usec, $sec) = explode(' ', microtime());
  $seed = (float) $sec + ((float) $usec * 100000);

  if (isset($useSeed))
    $seed = $useSeed;

  srand($seed);

  set_time_limit(5);


  //Define ingredients

  $weighedIngredients = array(
  );

  $liquidIngredients = array(
    "water",
    "lemonade",
    "orange juice",
    "milk",
    "tabasco sauce",
    "hot pepper sauce",
    "red wine",
    "white wine",
    "brandy",
	  "soy sauce",
	  "white wine vinegar",
    "essence of vanilla",
    "Absolut Citron",
    "Malibu Rum",
    "Vodka",
    "Baileys",
    "Rasberry Schnapps",
    "Martini"
  );

  $unitIngredients = array(
    "pinches of salt",
    "ice cubes",
    "little umbrellas",
    "olives"
  );

  //Define Instructions

  //these for ingredients with status UNUSED
  $initalInstructions = array(
    "open the %s",
    "put the %s into the cocktail mixer"
  );

  //these for status USED
  $instructions = array(
    "blend the %s",
    "stir the %s",
    "shake but don't stir",
    "shake with a suitable amount of stirring",
    "add the %s"
  );

  //one of these picked for very end
  $finalInstructions = array(
    "strain and serve",
    "pour over rocks",
    "strain into a glass"
  );

  //Define names

  $names = array(
    "Slippery %s",
    "Wet %s",
    "Super %s",
    "%s %s ultrablend"
  );



  //types
  define("WEIGHED", 0);
  define("LIQUID", 1);
  define("UNIT", 2);

  //statuses
  define("UNUSED", 0);
  define("USED", 1);
//define("COOKED", 2);
  define("THROWN", 99);

  //Ingredient class
  class Ingredient {
    var $type;
    var $name;
    var $quantity;
    var $status;
    var $uses;

    function Ingredient($type, $quantity, $name) {
      $this->type = $type;
      $this->quantity = $quantity;
      $this->name = $name;
      $this->used = false;
      $this->status = UNUSED;
      $this->uses = 0;
    }
  }

  //functions
  function pickIngredient($type, &$options) {
    if (sizeof($options) == 0) {
      return false;
    }

    switch ($type) {
      case WEIGHED: /*$units = (rand(1,15)*10)."g"; break;*/
      case LIQUID: $units = (rand(1,15)*10)."ml"; break;
      default: $units = rand(1,5); break;
    }

    $index = rand(0,sizeof($options)-1);

    $name = $options[$index];

    echo "<!-- pre: ".sizeof($options)."\n";
    array_splice($options, $index, 1);
    echo "post: ".sizeof($options)."-->\n";

    return new Ingredient($type, $units, $name);

  }

  /*function findIngredient($needStatus, &$ingredients) {
    $usables = array();

    for ($i = 0; $i < sizeof($ingredients); $i++) {
      $ingredient = $ingredients[$i];
      if ($ingredient->status <= $needStatus) {
        $usables[$i] = $ingredient;
      }

      if (sizeof($usables) > 0) {
        $r = rand(0,sizeof($usables)-1);
        $randIngredient = $usables[$r];

      }
      else return false;


    } //for
  }*/

  //store ingredients in these arrays
  $ingredients = array(
    UNUSED => array(),
    USED => array(),
    THROWN => array()
  );    

  $cooked = rand(0,2);
  
  //BEGIN :D

  $numberOfIngredients = rand(2, 5);

  for ($i = 0; $i < $numberOfIngredients; $i++) {
    $type = rand(1,2);
    switch ($type) {
      case WEIGHED: /*$ingredient = pickIngredient(WEIGHED, $weighedIngredients); break;*/
      case LIQUID: $ingredient = pickIngredient(LIQUID, $liquidIngredients); break;
      default: $ingredient = pickIngredient(UNIT, $unitIngredients); break;
    }
    if (is_object($ingredient)) {
      $ingredients[UNUSED][] = $ingredient;
    }
  }

  echo "<h1>Random Cocktail Generator</h1>";

  echo "<a href=\"$PHP_SELF\"><img src=\"refresh.gif\" border=\"0\"> Get new</a><br>";

  echo "<h2>".sprintf($names[rand(0,sizeof($names)-1)], $ingredients[UNUSED][rand(0,sizeof($ingredients[UNUSED])-1)]->name, $ingredients[UNUSED][rand(0,sizeof($ingredients[UNUSED])-1)]->name)."</h2>";

  reset($ingredients[UNUSED]);

  //printf("Serves %d<br>", rand(1,5));

  echo "<h3>You will need</h3><ul>";

  foreach ($ingredients[UNUSED] as $i) {
    echo "<li>".$i->quantity." ".$i->name."</li>";
  }

  echo "</ul><br><br>";

  echo "<h3>How to make it</h3>";

  echo "<ul>";

  if ($cooked > 0) {
    printf("<li>Chill on ice:</li>", rand(18,40)*10);
  }

  $loops = 0;

  while (sizeof($ingredients[UNUSED]) > 0) {
    if ($loops++ > 60) {
      break;
    }

    //first, pick a type
    $ingredientType = -1;
    while (sizeof($ingredients[$ingredientType]) == 0) {
      $ingredientType = rand(0,3);
      //echo "trying $ingredientType<br>";
      if ($loops++ > 60) {
        break 2;
      }
    }

    if ($ingredientType > -1) {

      echo "<li>";

      //echo "($ingredientType) ";
      
      $ingredient = new Ingredient("", "", "");
      $ingredient->uses = 100;
      
      $attempts = 5;
      while ($ingredient->uses > 2) { 
        $ingredientIndex = rand(0,sizeof($ingredients[$ingredientType])-1);

        $ingredient = $ingredients[$ingredientType][$ingredientIndex];
        if ($attempts-- == 0) {
          break;
        }
      }
      $ingredient->uses++;

      //shall we throw it away?
      $throw = (rand(0, 100) > 90) ? true : false;

      if ($throw) {
        array_splice($ingredients[$ingredientType], $ingredientIndex, 1);
        //echo "Adding $ingredient->name to thrown(".sizeof($ingredients[THROWN]).")<br>";
        $ingredients[THROWN][] = $ingredient;
        //echo "-> thrown(".sizeof($ingredients[THROWN]).")<br>";
        echo "discard the ".$ingredient->name;
      }
      else {
        if ($ingredientType == UNUSED) {
          //use it
          array_splice($ingredients[$ingredientType], $ingredientIndex, 1);
          $ingredients[USED][] = $ingredient;
          echo sprintf(
            $initalInstructions[rand(0,sizeof($initalInstructions)-1)],
            $ingredient->name
          );
        }
        else {
          //do something with it
          echo sprintf(
            $instructions[rand(0,sizeof($instructions)-1)],
            $ingredient->name
          );
        }
      }
      echo "</li>";
      /*echo "<br>";
      echo "Current usued: ".join(" ",$ingredients[UNUSED])."<br>";
      echo "Current used: ".join(" ",$ingredients[USED])."<br>";
      echo "Current thrown: ".join(" ",$ingredients[THROWN])."<br>";
      echo "<br>";*/
      
    }
  }

  /*if ($cooked > 0) {
    echo sprintf("<li>bake for %d minutes and serve hot</li>", rand(2,9)*10);
  }
  else {*/
    echo "<li>".$finalInstructions[rand(0,sizeof($finalInstructions)-1)]."</li>";
  //}

  echo "</ul>";

  echo "<hr>";
  echo "This recipe ID is <input type=\"text\" disabled=\"true\" size=\"12\" value=\"$seed\"><br><br>";
  echo "<form action=\"$PHP_SELF\" method=\"post\">View a recipe id: <input type=\"text\" name=\"useSeed\" size=\"12\"> <input type=\"submit\" value=\"View\"></form>";


?>