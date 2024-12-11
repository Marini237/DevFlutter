import 'package:flutter/material.dart';
import 'package:newflutterapp/models/user.dart';
import 'package:newflutterapp/models/post.dart';
import 'package:newflutterapp/pages/home.dart';

void main() {
  User shiipou = User(
    username: 'Shiipou',
    avatar: 'https://avatars.githubusercontent.com/u/38187238',
  );

  User github = User(
    username: 'GitHub',
    avatar:
        'https://github.githubassets.com/assets/starstruck-default-b6610abad518.png',
  );

  Post firstPost = Post(
    owner: shiipou,
    content:
        'Laborum magna occaecat anim deserunt est eu exercitation magna ipsum magna adipisicing. Cupidatat aliqua cillum proident culpa officia commodo et. Deserunt veniam aute consequat laborum enim minim sit exercitation irure consequat pariatur eu. Mollit adipisicing dolor do minim commodo commodo elit eiusmod Lorem consectetur occaecat amet.',
    image: 'https://images.unsplash.com/photo-1635365737298-3a64d9459d83',
    likes: [github],
  );

  Post commentAnswer = Post(
    owner: github,
    content:
        'Officia aliqua irure enim excepteur minim pariatur amet incididunt amet. Anim voluptate exercitation enim sit tempor cillum tempor culpa ipsum. Consectetur ipsum tempor voluptate aute. Minim magna duis dolore aute dolore non incididunt do ad cupidatat et velit laboris. Elit dolore duis aliqua sint consectetur qui in in nostrud aliqua magna deserunt. Excepteur laboris aliqua nostrud exercitation do cupidatat mollit duis ea aute sit aliqua occaecat.',
  );

  Post commentPost = Post(
    owner: shiipou,
    content:
        'Tempor ad sit id consequat culpa. Ut incididunt consectetur eiusmod ad tempor nostrud cupidatat. Est voluptate dolore aute ex.',
    comments: [commentAnswer],
  );

  Post sharedPost = Post(
    owner: github,
    content:
        'Eiusmod consequat et excepteur Lorem sint ad elit sit exercitation. Veniam ad duis magna veniam aliquip nisi. Culpa minim minim aliqua occaecat excepteur in ea anim sit.',
    embededPost: firstPost,
    comments: [commentPost],
    likes: [shiipou],
  );

  List<Post> posts = [
    firstPost,
    sharedPost,
    ...[
      'Proident dolore proident nisi sit nostrud commodo irure reprehenderit non consequat excepteur irure. In mollit id fugiat sint officia et tempor ex consectetur duis magna. Commodo mollit in quis exercitation amet tempor id magna cupidatat excepteur exercitation commodo. Dolore veniam do veniam consequat. Ex quis reprehenderit in veniam qui anim dolor Lorem. Proident eiusmod laborum irure nostrud ullamco ut cupidatat velit cillum nisi in laboris laboris.',
      'Minim culpa qui veniam do amet sint ex excepteur officia esse amet. Minim et ipsum ut esse dolor deserunt irure sunt. Nostrud elit sunt quis tempor nostrud in aute do culpa commodo commodo eu reprehenderit velit. Aliquip velit proident minim anim anim tempor laboris fugiat consectetur adipisicing dolor. Velit culpa incididunt et ex officia consectetur elit eu do ea eiusmod elit. Anim elit in mollit consectetur excepteur culpa pariatur adipisicing consectetur labore.',
      'Incididunt et sunt anim deserunt eu aliqua. Adipisicing et laborum mollit ut sunt dolore cillum deserunt exercitation. Dolor quis magna ex ipsum consequat esse.',
      'Aliqua irure eu laborum qui occaecat cupidatat exercitation aliqua aliquip occaecat. Est ea pariatur labore ullamco eiusmod elit excepteur in velit dolor culpa. Deserunt sit est excepteur do voluptate cillum. Est ea id nulla culpa exercitation tempor occaecat velit labore. Occaecat esse dolore dolor et non irure officia minim ad elit exercitation. Nostrud consectetur culpa laboris cillum ullamco exercitation ipsum quis consequat et occaecat veniam.',
      'Ad aute adipisicing deserunt fugiat est ea eiusmod eiusmod adipisicing consectetur. Minim veniam labore incididunt ea do nostrud eiusmod nisi irure pariatur est nisi. Enim laboris tempor incididunt cupidatat et dolore enim sunt nisi. Et culpa et excepteur eiusmod nisi. Ut nisi deserunt ut eiusmod reprehenderit eu nostrud sit.'
    ].map((text) => Post(owner: shiipou, content: text))
  ];

  runApp(MyApp(posts: posts));
}

class MyApp extends StatelessWidget {
  final List<Post> posts;

  const MyApp({super.key, required this.posts});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Fundamentals',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My Social Network'),
        ),
        body: HomePage(posts: posts),
      ),
    );
  }
}
