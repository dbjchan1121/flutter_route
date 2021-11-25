import 'package:flutter/material.dart';

import '../book.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book? book;
  const BookDetailsScreen({ Key? key, this.book }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book != null) ...[
              Text(book!.title, style: Theme.of(context).textTheme.headline6,),
              Text(book!.author, style: Theme.of(context).textTheme.subtitle1,)
            ]
          ],
        ),
      ),
    );
  }
}


class BookDetailsPage extends Page {
  final Book? book;

  BookDetailsPage({
    this.book,
  }) : super(key: ValueKey(book));

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, animation2) {
        final tween = Tween(begin: Offset(0.0, 2.0), end: Offset.zero);
        final curveTween = CurveTween(curve: Curves.easeInOut);
        return SlideTransition(
          position: animation.drive(curveTween).drive(tween),
          child: BookDetailsScreen(key: ValueKey(book), book: book),
        );
      }
    );
  }
}
