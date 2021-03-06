import 'package:flutter/material.dart';
import 'package:flutter_route/book.dart';
import 'package:flutter_route/pages/book_details_screen.dart';
import 'package:flutter_route/pages/book_list_screen.dart';
import 'package:flutter_route/pages/unknow_screen.dart';


class BookRoutePath {
  final int? id;
  final bool isUnknown;

  BookRoutePath.home()
      : id = null,
        isUnknown = false;

  BookRoutePath.details(this.id) : isUnknown = false;

  BookRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;

  bool get isDetailsPage => id != null;
}

class BookRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  Book? _selectedBook;
  bool show404 = false;

  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('了不起的程序员', '图灵出版社'),
    Book('粤语教程', '高石英')
  ];

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  BookRoutePath get currentConfiguration {
    if (show404) {
      return BookRoutePath.unknown();
    }

    return _selectedBook == null
      ? BookRoutePath.home()
      : BookRoutePath.details(books.indexOf(_selectedBook!));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: const ValueKey('BookListPage'),
          child: BooksListScreen(
            books: books,
            onTapped: _handleBookTapped
          )
        ),

        if (show404) 
          const MaterialPage(key: ValueKey('unknown page'), child: UnknownScreen())
        ///选中某一本书
        else if (_selectedBook != null)
          BookDetailsPage(book: _selectedBook)
          // MaterialPage(
          //   key: ValueKey(_selectedBook),
          //   child: BookDetailsScreen(book: _selectedBook)
          // )
      ],
      ///页面 pop 时 执行
      onPopPage: (route, result) {
        ///print('pop');
        if (!route.didPop(result)) {
          return false;
        }

        _selectedBook = null;
        show404 = false;
        notifyListeners();

        return true;
      },
    );
  }

  void _handleBookTapped(Book book) {
    print(_selectedBook);
    _selectedBook = book;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(BookRoutePath path) async {
    if (path.isUnknown) {
      _selectedBook = null;
      show404 = true;
      return;
    }
    if (path.isDetailsPage) {
      if (path.id! < 0 || path.id! > books.length - 1) {
        show404 = true;
        return;
      }
      _selectedBook = books[path.id!];
    } else {
      _selectedBook = null;
    }
    show404 = false;
  }
  
}

// 解析路由信息，处理路由路径
class BookRouteInformationParser extends RouteInformationParser<BookRoutePath> {
  @override
  Future<BookRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    // Handle '/'
    if (uri.pathSegments.length == 0) {
      return BookRoutePath.home();
    }

    // Handle '/book/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'book') return BookRoutePath.unknown();
      var remaining = uri.pathSegments[1];
      var id = int.tryParse(remaining);
      if (id == null) return BookRoutePath.unknown();
      return BookRoutePath.details(id);
    }

    // Handle unknown routes
    return BookRoutePath.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(BookRoutePath path) {
    if (path.isUnknown) {
      return RouteInformation(location: '/404');
    }
    if (path.isHomePage) {
      return RouteInformation(location: '/');
    }
    if (path.isDetailsPage) {
      return RouteInformation(location: '/book/${path.id}');
    }
    return null;
  }
  
}