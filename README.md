# ActiveRecordLite
Active Record Lite was a project I made that recreates some of the basic functionality of Rails' Active Record.

## SQLObject
SQLObject is my version of the ActiveRecord::Base class. It has getter and setter methods for all columns in the model's respective table. The key methods I chose to include are ::all, ::find, #insert, #update, and #save.
  
  ``` ::all ```: returns an array with all records in the database for that table.
  
  ``` ::find ```: returns an object from the database that matches the key given as an argument.
  
  ``` #insert ```: inserts an entry into the table to represent the calling object.
  
  ``` #update ```: updates the row in the table with the matching primary key.
  
  ``` #save ```: calls #insert or #save, depending on whether the object exists in the table yet.
  
## Searchable
SQLObject extends this module, and adds the SQLObject::where method to allow queries with (:column => value) arguments.

## Associations
This contains the code I wrote to enable associations between tables, like in Active Record. I included belongs_to, has_many, and has_one_through. You may specify a foreign key, class name, and primary key if any of these are not the default guess by Rails. The SQLObject extends the module that incorporates the classes than allow this behavior.
