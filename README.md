# Gilded - an iOS-Reddit-App
A simple iOS app designed primarily for phones that queries the Reddit API for "Hot", "Top", and "New" posts using a NSFetchRequest. Each query is parsed and converted into a .json object.

In the final product, each type of post is displayed on the proper navigation controller (there being one for "Hot" posts, one for "Top", and one for "New".)

#Author: Andrew Li, mail@andrewchinnli.com

## Overview

A simple iOS app that displays Reddit information pulled directly from the Reddit api. The information is distributed into "Hot", "Top", and "New" posts.

## Application Specifics
* The app loads into Hot posts by default.
* A tab bar is located on the bottom of the screen that will switch the type of posts shown.
* Posts can be saved to a local "History". These posts will then be shown in the history of the app.

## Status
App is working. Some intended features are not implemented yet. UI is minimal.

## Before you run the Application
* The application must be run in XCode. At a later point it might be distributed as an ipa.

## Running the Application
* Open the project in XCode, and build it.
