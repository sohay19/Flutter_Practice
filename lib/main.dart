import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

// REGION, MyAPP
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

// REGION, MyAppState
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

// REGION, MyHomePage
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// REGION, MyHomePageState
class _MyHomePageState extends State<MyHomePage> {
  // 네비게이션 레일 인덱스
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        // Placeholder = 교차 사각형의 UI
        page = Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            body: Row(
              children: [
                // SafeArea = 하위 항목이 하드웨어 노치나 상태 표시줄에 의해 가려지지 않도록 함
                SafeArea(
                  // NavigationRail = 왼쪽 메뉴바
                  child: NavigationRail(
                    // 가로 길이가 600이상일 경우에만 확장
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      // NavigationRailDestination = 각 메뉴
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                // NavigationRail 확장
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    // 선택된 페이지
                    child: page,
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}

// REGION, GeneratorPage
class GeneratorPage extends StatelessWidget {
  @override
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

    // Center = 수평 중앙
    return Center(
      // Column = 원하는 수의 자식을 가져와 위에서 아래로 열에 넣는 레이아웃 위젯
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 영단어 카드
          BigCard(pair: pair),
          SizedBox(height: 10),
          // 텍스트와 카드 사이의 간격 넓히기
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
        ],
      ),
    );
  }
}

// REGION, BigCard
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

