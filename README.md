<h1>Aplikacja wykorzystująca filtr kwadratowy</h1>

<b>Opis projektu</b>

Aplikacja desktopowa z interfejsem graficznym (GUI) napisana w C# WPF,
wykorzystująca algorytm filtra kwadratowego zaimplementowany w języku Asembler oraz C++.
Umożliwia przetwarzanie obrazów z wykorzystaniem wielowątkowości oraz obsługę zewnętrznych bibliotek DLL.

<b>Funkcjonalności</b>
<ul>
  <li>Interfejs użytkownika (GUI) w technologii WPF, zapewniający wygodną obsługę aplikacji.</li>
  <li>Obsługa przeciągnij i upuść (Drag and Drop) do dodawania obrazów w różnych formatach.</li>
  <li>Wielowątkowe przetwarzanie obrazu, pozwalające na równoczesne filtrowanie segmentów obrazu, co zwiększa wydajność działania na dużych plikach graficznych.</li>
  <li>Możliwość wyboru ilości wątków, na których działa część krytyczna kodu.</li>
  <li>Obsługa zewnętrznych bibliotek DLL, zawierających implementację algorytmu w C++ oraz Asemblerze.</li>
  <li>Asynchroniczne przetwarzanie obrazu, umożliwiające płynniejsze działanie aplikacji podczas przetwarzania danych.</li>
</ul>

<b>Technologie:</b>
<ul>
  <li>C# WPF – interfejs użytkownika oraz obsługa logiki aplikacji.</li>
  <li>C++ / Asembler – implementacja algorytmu filtra kwadratowego.</li>
  <li>Multithreading – optymalizacja przetwarzania obrazu poprzez podział na segmenty filtrowane jednocześnie.</li>
</ul>
<p>
<b>Autor:</b> Sorrger
</p>
