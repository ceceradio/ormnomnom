{Connection} = require '../../connection'
{AND, OR, NOT, SELECT, INSERT, UPDATE, DELETE} = require '../../constants'
{BASE_FIELDS, DBField} = require './fields'
{comparisons} = require './comparisons'

try
    sqlite3 = require 'sqlite3'
catch err
    try
        sqlite3 = require 'sqlite3/lib'
    catch err
        throw new Error '``sqlite3`` must be installed to use the sqlite3 backend.'

SQLiteWrapper = (client)->
    @client = client
    @

SQLiteWrapper::execute = (sql, values, mode, model, ready)->
    client = @client
    stmt = @client.prepare sql
    stmt_ready = (err, rows)->
        if err
            ready err, null
        else
            if mode is INSERT
                lastID = @lastID
                client.all "SELECT * FROM #{model._meta.db_table} WHERE \"_ROWID_\" = $1", lastID, (err, data)->
                    ready err, data
            else
                ready err, rows

    args = values.slice().concat(stmt_ready)

    stmt[if mode is INSERT then 'run' else 'all'].apply stmt, args
    stmt.on 'error', (err)->
        ready err

SQLiteWrapper::close = (ready)->
    @client.end()
    if ready instanceof Function then ready()

SQLiteConnection = (metadata)->
    @metadata = metadata
    @

SQLiteConnection:: = new Connection

SQLiteConnection::constraint = (constraint)->
    constraint

SQLiteConnection::quote = (what)->
    "\"#{what.replace /\"/g, '\"\"'}\""

SQLiteConnection::negotiate_type = (field, force_type)->
    BASE_FIELDS[force_type or field.db_type](field, @)

SQLiteConnection::comparison = (type)->
    comparisons[type]

SQLiteConnection::close = (ready)->
    @client (client)->
        client.close ready

SQLiteConnection::get_client =(ready)->
    config =
        database: @metadata.name

    db = new sqlite3.Database config.database, sqlite3.OPEN_READWRITE | sqlite3.OPEN_CREATE, (err)->
        if err then throw err
        ready new SQLiteWrapper db

SQLiteConnection::db_field_type =-> DBField

exports.Connection = SQLiteConnection
