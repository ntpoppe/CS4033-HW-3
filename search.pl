% Romanian road map. Undirected.
road(arad, zerind, 75).
road(arad, sibiu, 140).
road(arad, timisoara, 118).
road(zerind, oradea, 71).
road(oradea, sibiu, 151).
road(timisoara, lugoj, 111).
road(lugoj, mehadia, 70).
road(mehadia, drobeta, 75).
road(drobeta, craiova, 120).
road(sibiu, fagaras, 99).
road(sibiu, rimnicu_vilcea, 80).
road(rimnicu_vilcea, pitesti, 97).
road(rimnicu_vilcea, craiova, 146).
road(pitesti, craiova, 138).
road(pitesti, bucharest, 101).
road(fagaras, bucharest, 211).
road(bucharest, giurgiu, 90).
road(bucharest, urziceni, 85).
road(urziceni, hirsova, 98).
road(hirsova, eforie, 86).
road(urziceni, vaslui, 142).
road(vaslui, iasi, 92).
road(iasi, neamt, 87).

% These edge wrappers are needed for the graph to be undirected.
% For example, if road(arad, sibiu, 140) exists (it does), 
% then edge(sibiu, arad, 140) and edge(arad, sibiu, 140) will succeed.
% It is just used to not duplicate road facts.
edge(A, B, D) :- road(A, B, D).
edge(A, B, D) :- road(B, A, D).

% BFS:
% Entry point. Goal fixed to bucharest.
bfs(Start, Path, Cost) :-
    Goal = bucharest,
    (
        % Initialize the queue with a single path @ start
        bfs_queue([[Start]], Goal, RevPath),
        % Prepending entries to path list is O(1), so we do that instead of appending (O(n)).
        % As a result of that, we need to reverse the path after.
        reverse(RevPath, Path),
        path_cost(Path, Cost)
    ;   Path=[], Cost=0
    ).

% Base case: front of queue starts with Goal. Return that path.
bfs_queue([[Goal|RestPath] | _], Goal, [Goal|RestPath]) :- !.

% Expand the first path in the queue.
bfs_queue([[Current|RestPath] | OtherPaths], Goal, Solution) :-
    % Generate all children (neighboring cities) that aren’t already in this path.
    findall([Next, Current | RestPath],
            ( edge(Current, Next, _), % Resolves road fact in either direction as described earlier.
                \+ member(Next, [Current|RestPath])  % Avoids revisiting the same city.
            ),
            Children),
    % Since this is breadth-first, add all new child paths to the back of the queue.
    append(OtherPaths, Children, NewQueue),
    % Recursively call with the updated queue until Goal is found.
    bfs_queue(NewQueue, Goal, Solution).

% Computes total travel cost.
path_cost([_], 0). % Base case: a single city has no cost.
path_cost([A,B|T], Cost) :-
    edge(A, B, D), % Get distance between consecutive cities.
    path_cost([B|T], Rest), % Recursively sum remaining edges.
    Cost is D + Rest. % Accumulate total distance.

% Example calls:
% bfs(oradea, Path, Cost).
% bfs(timisoara, Path, Cost).

% dfs
% entry points, goal is fixed to Bucharest
dfs(Start, Path, Cost) :-
    Goal = bucharest,
    (
        %initialize the qeueu with one path at the start. The queue in DFS is more like a stack because it is last in first out, the children will go to the front of the queue
        dfs_queue([[Start]], Goal, RevPath),
        % Prepending entries to path list is O(1), so we do that instead of appending (O(n)).
        % As a result of that, we need to reverse the path after.
        reverse(RevPath, Path),
        path_cost(Path, Cost)
    ;   Path=[], Cost=0
    ).


% the base case is when the first path that is in the queue starts with
% the goal city. It will return that path.
dfs_queue([[Goal|RestPath] | _], Goal, [Goal|RestPath]) :- !.

% This will take one neighbroing city that is unvicited and recursively
% expand the first path in the queue. Then the path will be added to the
% front of th queue.
dfs_queue([[Current|RestPath] | OtherPaths], Goal, Solution) :-
    %gets a city next to the current one, which will create an edge from current to next
    edge(Current, Next, _),
    %makes sure that the neighbor city hasn't already been visited
    \+ member(Next, [Current|RestPath]),
    %add the new path to the front of the queue. In DFS the queue acts like a stack because the new paths are added to the front.
    NewQueue = [[Next, Current | RestPath] | OtherPaths],
    %search with recursion using the updated queue
    dfs_queue(NewQueue, Goal, Solution).

% this will remove the current path from the queue if it has no more
% neighboring cities available. Then it will continue with the remaining
% paths
dfs_queue([_ | OtherPaths], Goal, Solution) :-
    dfs_queue(OtherPaths, Goal, Solution).
