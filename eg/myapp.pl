#!/usr/bin/env perl

use Mojolicious::Lite;
use lib '../lib', '../t/lib';
use Local::Schema;

my $schema = Local::Schema->connect(
    'dbi:SQLite:data.db',
);
plugin DBIC => {
    schema => $schema,
};

get '/notes' => {
    controller => 'DBIC',
    action => 'list',
    resultset => 'Notes',
    template => 'notes.list',
} => 'notes.list';

get '/notes/:id' => {
    controller => 'DBIC',
    action => 'get',
    resultset => 'Notes',
    template => 'notes.get',
} => 'notes.get';

any [qw( GET POST )], '/notes/:id/edit' => {
    controller => 'DBIC',
    action => 'set',
    resultset => 'Notes',
    template => 'notes.edit',
    forward_to => 'notes.get',
} => 'notes.edit';

any [qw( GET POST )], '/notes/:id/delete' => {
    controller => 'DBIC',
    action => 'delete',
    resultset => 'Notes',
    template => 'notes.delete',
    forward_to => 'notes.list',
} => 'notes.delete';

get '/events' => {
    controller => 'DBIC',
    action => 'list',
    resultset => 'Events',
    template => 'events.list',
} => 'events.list';

app->start;
__DATA__
@@ notes.list.html.ep
<h1>Notes</h1>
<p>[<%= link_to Create => 'notes.create' %>]</p>
<ul>
    % for my $row ( $resultset->all ) {
        <li><%=
            link_to $row->title,
                'notes.get', { id => $row->id }
        %></li>
    % }
</ul>

@@ notes.get.html.ep
% title $row->title;
%= link_to 'Back' => 'notes.list'
<h1><%= $row->title %></h1>
%== $row->description
<p>
    [<%= link_to 'Edit' => 'notes.edit' %>]
    [<%= link_to 'Delete' => 'notes.delete' %>]
</p>

@@ notes.edit.html.ep
%= form_for current_route, method => 'POST', begin
    %= csrf_field
    %= text_field 'title'
    %= text_area 'description'
    %= submit_button
% end

@@ notes.delete.html.ep
%= button_to 'Cancel' => 'notes.get'
%= button_to 'Delete' => 'notes.delete', method => 'POST'

@@ events.list.html.ep
<ul>
    % for my $row ( $resultset->all ) {
        <li><%= $row->title %></li>
    % }
</ul>

