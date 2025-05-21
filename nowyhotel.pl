%%% BAZA WIEDZY %%%

:- dynamic room/5.
:- dynamic guest/4.

% Fakty o pokojach
% room(RoomID, RoomType, Beds, Price, Available).
room(101, single, 1, 100, yes).
room(102, double, 2, 150, yes).
room(103, family, 4, 250, no).
room(104, suite, 3, 300, yes).

% Fakty o go�ciach
% guest(GuestID, Name, NumGuests, Preferences).
guest(1, 'Anna Nowak', 1, [view, quiet]).
guest(2, 'Jan Kowalski', 2, [family, extra_bed]).

% Fakty o rezerwacjach
% reservation(ReservationID, GuestID, RoomID, Days).
reservation(1, 1, 101, 3).
reservation(2, 2, 103, 2).

% Fakty o zam�wieniach restauracyjnych
% order(OrderID, GuestID, Item, Cost).
order(1, 1, 'Breakfast', 30).
order(2, 1, 'Dinner', 50).
order(3, 2, 'Lunch', 40).

%%% REKURENCJA %%%

% Sprawdzanie dost�pno�ci pokoju
available_room(RoomID) :-
    room(RoomID, _, _, _, yes).

% Liczenie kosztu pobytu - zwraca wynik
stay_cost(ReservationID, TotalCost) :-
    reservation(ReservationID, GuestID, RoomID, Days),
    room(RoomID, _, _, Price, _),
    order_cost(GuestID, OrderCost),
    TotalCost is (Price * Days) + OrderCost.

% Liczenie kosztu zam�wie�
order_cost(GuestID, Total) :-
    findall(Cost, order(_, GuestID, _, Cost), Costs),
    sum_list(Costs, Total).

% Rekurencyjne znajdowanie odpowiedniego pokoju (wg liczby go�ci)
find_suitable_room([RoomID|_], Guests, RoomID) :-
    room(RoomID, _, Beds, _, yes),
    Beds >= Guests.

find_suitable_room([_|Rest], Guests, SuitableRoom) :-
    find_suitable_room(Rest, Guests, SuitableRoom).

find_preferred_room([RoomID|_], Guests, Preferences, RoomID) :-
    room(RoomID, Type, Beds, _, yes),
    Beds >= Guests,
    member(Type, Preferences).

find_preferred_room([_|Rest], Guests, Preferences, RoomID) :-
    find_preferred_room(Rest, Guests, Preferences, RoomID).

% Sugeruj pok�j uwzgl�dniaj�c preferencje
suggest_room_for_guest(GuestID, RoomID) :-
    guest(GuestID, _, NumGuests, Preferences),
    findall(ID, room(ID, _, _, _, _), RoomList),
    find_preferred_room(RoomList, NumGuests, Preferences, RoomID).

%%% INTERFEJS U�YTKOWNIKA %%%

% Wyszukaj dost�pne pokoje
check_available_rooms(Rooms) :-
    findall(RoomID, available_room(RoomID), Rooms).

% Liczenie kosztu pobytu - wypisuje wynik
display_stay_cost(ReservationID) :-
    stay_cost(ReservationID, TotalCost),
    format('Total stay cost: ~w', [TotalCost]).

%%% ZARZ�DZANIE DOST�PNO�CI� POKOI %%%

% Zmie� dost�pno�� pokoju
set_room_available(RoomID, Availability) :-
    retract(room(RoomID, Type, Beds, Price, _)),
    assertz(room(RoomID, Type, Beds, Price, Availability)).

% Rezerwuj pok�j (ustawia dost�pno�� na "no")
reserve_room(RoomID) :-
    set_room_available(RoomID, no).

% Zwolnij pok�j (ustawia dost�pno�� na "yes")
release_room(RoomID) :-
    set_room_available(RoomID, yes).

%%% ZARZ�DZANIE GO��MI %%%

% Dodaj nowego go�cia
add_guest(GuestID, Name, NumGuests, Preferences) :-
    assertz(guest(GuestID, Name, NumGuests, Preferences)).

% Usu� go�cia i powi�zane dane (opcjonalnie mo�na rozbudowa�)
delete_guest(GuestID) :-
    retractall(guest(GuestID, _, _, _)),
    retractall(reservation(_, GuestID, _, _)),
    retractall(order(_, GuestID, _, _)).
