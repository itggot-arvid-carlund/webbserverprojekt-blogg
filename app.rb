require 'sinatra'
require 'sqlite3'
require 'slim'
require 'byebug'
require 'BCrypt'
enable :session

get('/') do
    slim(:index)
end

get('/login') do
    slim(:login)
end

get('/create') do
    slim(:create)
end

get('/welcome') do
    slim(:welcome)
end

get('/profile/:id') do
    if session[:loggedin] == true
    slim(:profile)
    else
        redirect('login')
    end
end

post('/login') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true
    result = db.execute("SELECT username, password FROM users WHERE username = ?", params["username"])
    if result.length > 0 && BCrypt::Password.new(result.first["password"]) == params["password"]
        session[:username] = result.first["username"]
        session[:id] = result.first["id"]
        session[:loggedin] = true
        redirect('/profile')
    else 
        redirect('/')
    end
end

post('/create') do
    db = SQLite3::Database.new("db/dbsave.db")
    db.results_as_hash = true

    hased_password = BCrypt::Password.create(params["password"])
    db.execute("INSERT INTO users (username,password) VALUES (?,?)",params["username"], hased_password)
    redirect('login')
end

#List Posts
get('/welcome') do
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true

     result = db.execute("SELECT users.name, users.email, users.tel, departments.title, users.id from users INNER JOIN departments on users.department_id = departments.id ")

     slim(:users, locals:{ users: result})
end

#CREATE
post('/users2') do
    #ansluta till DB
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true

    # Plocka upp parametrarna ifrån formuläret
    new_name = params["name"]
    new_email = params["email"]
    new_tel = params["tel"]
    new_department = params["department"]

    # Skicka iväg till databsen med SQL
    department_nummer = db.execute("SELECT id FROM departments WHERE title=?", new_department)
    department_nummer = department_nummer.first["id"] #Ger oss siffran 1 (id)

    # Skicka iväg till databsen med SQL
    db.execute("INSERT INTO users (name,email,tel,department_id) VALUES (?,?,?,?)",new_name,new_email,new_tel,department_nummer)

    #Redirect till anann GET
    redirect('/')
end

#Visible
get('/users/:id') do
    db = SQLite3::Database.new("db/users.db")
    db.results_as_hash = true

    user_id = params["id"]

    result = db.execute("SELECT users.name, users.email, users.tel, departments.title, users.id FROM users INNER JOIN departments ON users.department_id = departments.id WHERE users.id = ?", user_id)
    slim(:seperate_user, locals:{users: result})
end

#EDIT USERS
get('/users/:id/edit') do
    slim(:edit_user)
end

post('/users/:id/edit_user') do
    db = SQLite3::Database.new("db/users.db")
    db.execute("UPDATE users SET name = ?, email = ?, tel = ?, department_id = ? WHERE id = ?",params["name"],params["email"],params["tel"], params["department"], params["id"])
    redirect(:users)
end