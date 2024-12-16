---
layout: post
title: Making Tic Tac Toe for Android
tags: [blog, blogger, android, java]
---

<p class="message"> This was a blog post originally published in 2013 on <a
href="https://web.archive.org/web/20160204235616/http://lyndonarmitage.com/making-tic-tac-toe-in-android">Blogger</a>.<br
/> I have resurrected it for posterity, there are other posts from my Blogger
that have since disappeared.</p>

In my last blog post I showed a little cheating application I made for the
Android which is sort of related to games (word games to be precise) so today
in this post I thought I’d explain how I made a simple Tic Tac Toe Application
for the Android phone (that’s Noughts and Crosses for us Brits).

## Setting Up

First of all you create a new Android project in whatever IDE you are using, I
am using IntelliJ Idea so I went to File|New Project:

<img
  title='I have it in its Dark Theme'
  src='{{ "assets/blogger/tic-tac-toe/NewProject1.png" | absolute_url }}'
  class='blog-image'
/>

In Eclipse you would go to File|New|Android Application Project:

<img
  title='I quite like the configuration options you get here.'
  src='{{ "assets/blogger/tic-tac-toe/NewProject2.png" | absolute_url }}'
  class='blog-image'
/>

I have a few SDKs installed on my machine including the latest, the one my
phone runs on and the one just below what my old phone ran on (2.2) so to make
sure this worked for the most devices I opted for an SDK versions in the 2’s (I
ended up using 2.3, Gingerbread).

Next I set up a few things in the files, nothing to major to note about, I did
make a mistake in my Project name that I just corrected in one of the xml files
but decided not to change it at an actual project level (partly to do with the
fact I had already created and pushed a GitHub page under the name).

## The Layout

The next thing I did was design the application layout. The file in my case was
generated and called main.xml and was located in the res folder under the
layout subfolder, it may of been called something else in an Eclipse project
but it should be the only file located in that subdirectory.

This was relatively easy as Idea has a very nice UI designing tool, as does
Eclipse. I settled on this:

<img
  title=''
  src='{{ "assets/blogger/tic-tac-toe/DesignIdea.png" | absolute_url }}'
  class='blog-image'
/>

That’s:

- A TextView with my name and the title of the game in it.
- A Button with the words New Game in it.
- A TableLayout containing within a Button in the 1st, 2nd and 3rd cell of 3
  different rows.

I have modified each item to look how I would like them to look:

- The TextView has had it’s layout:gravity set to centre it horizontally.
- The Button has also had it’s layout:gravity set to centre it horizontally.
  And has also had it’s layout:width set to fill the parent.
- The TableLayout has had it’s layout:gravity set to centre both horizontally
  and vertically.
- Each Button within the TableLayout have had their width and height attributes
  set to 100dp so they appear square.

I won’t show you the actual xml file for this in it’s pure form as I think it’s
better you experiment yourself.

I also modified the AndroidManifest.xml file (located at the root of your
project) to prevent the application being rotated into landscape by adding:

```xml
android:screenOrientation="portrait"
```

To the activity tag.

## Onto the Code

Now finally the code!

When you begin a new Android project you are probably presented with a java
file similar to this (minus the comments and typo):

```java
package com.example.NaughtsAndCrosses;
 
import android.app.Activity;
import android.os.Bundle;
 
/**
 * Tic Tac Toe Game
 * ---
 * 
 * Code by Lyndon Armitage
 * For learning purposes
 *
 * @author Lyndon Armitage
 */
public class MainActivity extends Activity {
    /**
     * Called when the activity is first created.
     */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
    }
}
```

Our first port of order is deciding how we are going to represent the game
state. So to do this we need to establish some facts namely; there are only 2
players (X and O) and the board is laid out in a 3 by 3 grid of either Xs, Os
or blanks.

From these facts I decided to go with:

```java
// Representing the game state:
private boolean noughtsTurn = false; // Who's turn is it? false=X true=O
private char board[][] = new char[3][3]; // for now we will represent the boar
```

An alternative to using the char array is using an array of an Enum but a
simple char array will do for now. Likewise I could of also used an Enum for
determining who’s turn it was.

Now we know how we are going to represent the game state we need to figure out
how we are going to interact with it. Technically I already decided this, by
using Buttons in a TableLayout and a button outside it to start a new game.

The first thing I decided to get working was interacting with each button in
the layout; changing what they have written on them and what they do when
clicked. This was actually more complicated to code than I expected. Originally
I thought there would be a simple call to the TableLayout to get the element in
a certain position, something like `getViewAt(int x, int y)` but there was not.
This is because the TableLayout can contain data not in rows and columns, e.g.
it can contain an EditText Element below or in between it’s normal TableRows.
Example:

<img
  title='Could come in handy actually'
  src='{{ "assets/blogger/tic-tac-toe/ExampleOfEditText.png" | absolute_url }}'
  class='blog-image'
/>

When you think about it this makes sense in designing a layout, it means you
can have heading for different parts of the grid.

So in order to get the position of each button we have to look at each of the
TableRow objects contained within it and use their positions as the y
coordinate and the Buttons position within them as the x coordinate:

```java
/**
 * This will add the OnClickListener to each button inside out TableLayout
 */
private void setupOnClickListeners() {
    TableLayout T = (TableLayout) findViewById(R.id.tableLayout);
    for(int y = 0; y < T.getChildCount(); y ++) {
        if(T.getChildAt(y) instanceof TableRow) {
            TableRow R = (TableRow) T.getChildAt(y);
            for(int x = 0; x < R.getChildCount(); x ++) {
                View V = R.getChildAt(x); // In our case this will be each button on the grid
                V.setOnClickListener(new PlayOnClick(x, y));
            }
        }
    }
}
```

I will explain what `PlayOnClick` is in a moment. What that code does is it
grabs the tableLayout and loops through each of it’s children (making sure each
one is a TableRow) and then loops through each child’s children and sets up
what they do upon a click. I had to edit my TableLayout and give it an ID to it
in order to find it using `findViewById()` I simply set up it’s android:id
attribute in the xml to:

```xml
android:id="@+id/tableLayout"
```

`PlayOnClick` is a custom `OnClickListener` I created for this program. I could
of instead created 9 different methods (one for each button) and set each
button to call one each using the UI designer but instead opted to create an
`OnClickListener` and dynamically set each button to use one with it’s unique
coordinates. An implementation of this for our game looks like this (it’s an
inner class of my `MainActivity` class):

```java
/**
 * Custom OnClickListener for Noughts and Crosses
 * Each Button for Noughts and Crosses has a position we need to take into account
 * @author Lyndon Armitage
 */
private class PlayOnClick implements View.OnClickListener {
 
    private int x = 0;
    private int y = 0;
 
    public PlayOnClick(int x, int y) {
        this.x = x;
        this.y = y;
    }
 
    @Override
    public void onClick(View view) {
        if(view instanceof Button) {
            Button B = (Button) view;
            board[y] =  noughtsTurn ? 'O' : 'X';
            B.setText(noughtsTurn ? "O" : "X");
            B.setEnabled(false);
            noughtsTurn = !noughtsTurn;
        }
    }
}
```

Now if you were to run this as it was it would be a playable version of Tic Tac
Toe, albeit without any score tracking and win checking. Not only that but, the
New Game Button does nothing, so let’s change that.

```java
/**
 * Called when you press new game.
 * @param view the New Game Button
 */
public void newGame(View view) {
    noughtsTurn = false;
    board = new char[3][3];
    resetButtons();
}
 
/**
 * Reset each button in the grid to be blank and enabled.
 */
private void resetButtons() {
    TableLayout T = (TableLayout) findViewById(R.id.tableLayout);
    for (int y = 0; y < T.getChildCount(); y++) {
        if (T.getChildAt(y) instanceof TableRow) {
            TableRow R = (TableRow) T.getChildAt(y);
            for (int x = 0; x < R.getChildCount(); x++) {
                if(R.getChildAt(x) instanceof Button) {
                    Button B = (Button) R.getChildAt(x);
                    B.setText("");
                    B.setEnabled(true);
                }
            }
        }
    }
}
```

I set the New Game button to call the corresponding method using my UI editor
and now when I click it I clear the grid. I also added a call `resetButtons()`
into the `onCreate()` method to make sure all the buttons are blank.

Now what about checking for a win? Well I know that whenever 3 of the items in
a line match that specific player has won so let’s go about coding a method
that works this out and appropriately responds.

Below is my implementation of a method that can check if a specific player has
won at a game of tic tac toe for any size board, it could probably be improved
and simplified into only one loop but that may be harder to understand:

```java
/**
 * This is a generic algorithm for checking if a specific player has won on a tic tac toe board of any size.
 *
 * @param board  the board itself
 * @param size   the width and height of the board
 * @param player the player, 'X' or 'O'
 * @return true if the specified player has won
 */
private boolean checkWinner(char[][] board, int size, char player) {
    // check each column
    for (int x = 0; x < size; x++) {
        int total = 0;
        for (int y = 0; y < size; y++) {
            if (board[y] == player) {
                total++;
            }
        }
        if (total >= size) {
            return true; // they win
        }
    }
 
    // check each row
    for (int y = 0; y < size; y++) {
        int total = 0;
        for (int x = 0; x < size; x++) {
            if (board[y] == player) {
                total++;
            }
        }
        if (total >= size) {
            return true; // they win
        }
    }
 
    // forward diag
    int total = 0;
    for (int x = 0; x < size; x++) {
        for (int y = 0; y < size; y++) {
            if (x == y && board[y] == player) {
                total++;
            }
        }
    }
    if (total >= size) {
        return true; // they win
    }
 
    // backward diag
    total = 0;
    for (int x = 0; x < size; x++) {
        for (int y = 0; y < size; y++) {
            if (x + y == size - 1 && board[y] == player) {
                total++;
            }
        }
    }
    if (total >= size) {
        return true; // they win
    }
 
    return false; // nobody won
}
```

I call the above method within another that handles what to do if a player has
won:

```java
/**
 * Method that returns true when someone has won and false when nobody has.
 * It also display the winner on screen.
 *
 * @return
 */
private boolean checkWin() {
 
    char winner = '\0';
    if (checkWinner(board, 3, 'X')) {
        winner = 'X';
    } else if (checkWinner(board, 3, 'O')) {
        winner = 'O';
    }
 
    if (winner == '\0') {
        return false; // nobody won
    } else {
        // display winner
        TextView T = (TextView) findViewById(R.id.titleText);
        T.setText(winner + " wins");
        return true;
    }
}
```

The TextView I describe there is the same one that has my name in it when you
look back to the design, this way the players can see who has won.

Now we simply need to edit the `onClick` method of our `PlayOnClick` class to
utilise this method correctly:

```java
public void onClick(View view) {
    if (view instanceof Button) {
        Button B = (Button) view;
        board[y] = noughtsTurn ? 'O' : 'X';
        B.setText(noughtsTurn ? "O" : "X");
        B.setEnabled(false);
        noughtsTurn = !noughtsTurn;
 
        // check if anyone has won
        if (checkWin()) {
            disableButtons();
        }
    }
}
```

The method `disableButtons()` simply disables all the buttons within the grid
to stop you playing after a win.

And that’s it! Tic Tac Toe on Android step by step!

<img
  title='Live on my phone'
  src='{{ "assets/blogger/tic-tac-toe/Screenshot_2013-01-12-17-21-00.png" | absolute_url }}'
  class='blog-image'
/>

I have a GitHub Repository with all this code available
[here](https://github.com/LyndonArmitage/NaughtsAndCrosses) if you want to see
the finished code.

Possible improvements include:

- Score keeping
- Bigger grids
- Online play
- An AI to play against
- Pretty Colours
- Optimisations

If you want to use the code feel free, provided you aren’t making money off of
it or calling it your own (it took me time and effort to make it after all).

**Happy Coding!**
