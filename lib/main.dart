import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Practice',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// 랜덤 영단어 생성
// 앱이 작동하는데에 필요한 데이터 정의
// ChangeNotifier -> 자신의 변경사항을 알릴 수 있음
class MyAppState extends ChangeNotifier {
  // 현재 단어
  var current = WordPair.random();

  // 하트를 누른 단어 모음
  var favorites = <WordPair>[];

  // 다음 영어 단어로 변경 후, 모든 위젯에 알림
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // 하트 누르기 OR 취소
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

//
class MyHomePage extends StatelessWidget {
  @override
  // build() = 위젯이 항상 최신 상태를 유지하도록 위젯의 상황이 바뀔 때마다 자동으로 호출되는 메서드
  // 위젯 또는 중첩된 위젯 트리를 반환해야함
  Widget build(BuildContext context) {
    // 앱의 현재 상태에 대한 변경 사항을 추적
    var appState = context.watch<MyAppState>();
    // 현재 영단어
    var pair = appState.current;

    // 하트 아이콘
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    // Scaffold = 최상위 위젯
    return Scaffold(
      // Column = 원하는 수의 자식을 가져와 위에서 아래로 열에 넣는 레이아웃 위젯
      // Center = 수평 중앙
      body: Center(
        child: Column(
          // 수직 중앙
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 수정 후 바로 저장 -> 핫 리로드 -> 실행 중인 시뮬레이터에 바로 반영
            Text('A random AWESOME idea:'),
            // 텍스트와 카드 사이의 간격 넓히기
            SizedBox(height: 10),
            BigCard(pair: pair),
            // 카드와 버튼 사이의 간격 넓히기
            SizedBox(height: 10),
            Row(
              // 버튼 추가
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 좋아요 버튼
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text('Like'),
                ),
                // 버튼 간격
                SizedBox(width: 10),
                // 다음 버튼
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next'),
                ),
              ],
            )
          ], // 후행 쉼표가 없어도 되지만 일반적으로 사용하는 것을 추천, 자동 줄바꿈의 힌트
        ),
      ),
    );
  }
}

// 기존에 작성된 Text(pair.asLowerCase) 코드에서 Extract Widget
// 위젯화하여 사용
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // 테마 설정
    var theme = Theme.of(context);
    // 스타일 설정
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // Padding을 다시 Card라는 위젯으로 감싸기
    return Card(
      // Padding이라는 위젯으로 감싸서 사용
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        // 스타일 적용
        child: Text(
          pair.asLowerCase,
          style: style,
          // 스크린리더 사용 시 잘못 인식됨을 막기위해
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}
