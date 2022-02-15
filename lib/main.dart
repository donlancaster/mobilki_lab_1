import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lab_1/developers_page.dart';
import 'package:lab_1/scores_page.dart';
import 'package:lab_1/sqflite/scores_repository.dart';
import 'package:social_share/social_share.dart';

import 'entity/score.dart';

void main() => runApp(const MyApp());
//stateless widget - как контейнер в html. все в проге - виджет
//у каждого stateless-виджета есть метод build
//поэтому override

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  void _preCacheImages(BuildContext context) {
    //анимации сердечек в кеш
    //если не вызовем функцию, картинки будут кешироваться в рантайме
    precacheImage(const AssetImage('assets/images/cat-food-hearts-icon-0.png'), context);
    precacheImage(const AssetImage('assets/images/cat-food-hearts-icon-1.png'), context);
    precacheImage(const AssetImage('assets/images/cat-food-hearts-icon-2.png'), context);
    precacheImage(const AssetImage('assets/images/cat-food-hearts-icon-3.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    _preCacheImages(context);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(title: 'Feed the cat'), //
    );
    //возвращает виджет
  }
}

class MainPage extends StatelessWidget {
  final String title;

  const MainPage({Key? key, required this.title}) : super(key: key);
  //ключи нужны для идентификации одинаковых виджетов, но мы это не юзаем

  @override
  Widget build(BuildContext context) {
    return _MainPage(
      title: title,
      deviceWidth: MediaQuery.of(context).size.width,
    );
  }
}

class _MainPage extends StatefulWidget { //_ значит что класс будет виден только внутри этого файла (private)
  //stateful widget -
  //есть визуальное отображение, а есть объект state, который хранит состояние виджета (поля)
  //как только меняем стейт, виджет меняет все сам
  //stateful виджет сам перестроится, а stateless ниче не сделает

  const _MainPage({Key? key, required this.title, required this.deviceWidth}) : super(key: key);

  final String title;
  final double deviceWidth;

  @override
  State<_MainPage> createState() => _MainPageState();
  //
}



class _MainPageState extends State<_MainPage> with SingleTickerProviderStateMixin {
  //late - говорим, что мы инициализируем поле до его использования
  //счетчик
  late final Score _score;
  //картинка
  late String _current;
  //ширина картинки в пикселях (наверное) для анимации
  final double _foodWidth = 92.35;
  //контроллер для анимации
  late AnimationController _animationController;
  //класс который хранит начальное и конечное значение. Он не содежржит объект, но содержит данные о направлении (что куда едет)
  late Animation _animation;
  //таймер. анимация раз в 4 секунды запускается
  late Timer _animationTimer;
  //чтобы нажать можно было только один раз за анимацию
  bool _singleInc = true;

  //перед билдом. вызывается один раз
  @override
  void initState() {
    _score = ScoresRepository.newScore();
    _current = 'assets/images/cat-food-hearts-icon-0.png';

    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationTimer = Timer.periodic(const Duration(milliseconds: 2500), (t) {
     //
      _singleInc = true;
     //возвращаем анимацию на старт
      _animationController.reset();
      //начинает анимацию
      _animationController.forward();
    });

    //Tween - класс для анимации
    _animation = Tween<double>(
      begin: -_foodWidth,
      end: (widget.deviceWidth - _foodWidth) / 2,
    ).animate(_animationController) //передаем контроллер
      ..addListener(() => setState(() {/* если я хочу изменить поля чтобы виджет перестроился*/}));
    //если мы хотим вызвать какую-то функцию вызвать при инициализации, ..
    // = _animation.addListener()
  //setStateO() - перестраивает полностью виджет. Когда текущее положение пакета с едой изменилось, нужно перестроить виджет
    //если мы хотим, чтобы виджет перестроился, вызываем setState()
    super.initState();
  }

  //неуправляемые ресурсы
  @override
  void dispose() {
    _animationController.dispose();
    _animationTimer.cancel();
    super.dispose();
  }

  void _incrementCounter() {
    //anim value - текущее положиение
    //-5 - погрешнотсь 5 пикселей
    if (_animation.value >= (widget.deviceWidth - _foodWidth) / 2 - 5 && _singleInc) {
      //если сработало, синглИнк меняем
      _singleInc = false;
      //нужно перестроить виджет счетчика - setState()
      setState(() {
        //увеличиваем счет
        //сначала увеличит счет, потом перестроит
        ScoresRepository.incScore(_score);
        if (_score.amount % 15 == 0) {
          _animate();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //scaffold - виджет, который заполняет всё экранное пространство
    return Scaffold(
      //appBar - верхняя панель - необязательный. Скафолду можно вообще ничего не передавать, будет просто белый экран
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () { //событие нажатия
              Navigator.push( //открывает следующую страницу
                //по сути есть стек страниц, чтобы перейти в следующую - push, вернуться - pop.
                context,
                //context - текущее состояние дерева виджетов... просто везде передется
                MaterialPageRoute(builder: (context) => const ScoresPage()),
              );
            },
            icon: const Icon(Icons.list_alt_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DevelopersPage()),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Center( //center центрирует все элементы
        child: Column(//все элементы в столбик
          mainAxisAlignment: MainAxisAlignment.center, //выравнивание внутри столбца
          children: <Widget>[
            Image.asset( //картинка с котом
              _current,
              scale: 1,
            ),
            const SizedBox( //пустой квадрат
              height: 15,
            ),
            const Text(
              'You have fed this cat this many times:',
            ),
            Text(
              '${_score.amount}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 25,
            ),
            //
            Stack(
              children: [
                Align(
                  //пакет с едой
                  //угол
                  alignment: Alignment.centerLeft,
                  //Transform.Translate
                  child: Transform.translate(
                    offset: Offset(_animation.value, 0),
                    child: SizedBox(
                      height: 130,
                      child: Image.asset(
                        'assets/images/cat-food.png',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                Align(//кнопка по центру
                  alignment: Alignment.center,
                  //GestureDetector - виджет, который отслеживает нажатия
                  child: GestureDetector(
                    child: SizedBox(
                      height: 130,
                      child: Image.asset(
                        'assets/images/cat-food.png',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    onTap: _incrementCounter, //когда мы нажимаем по его ребенку, вызывается onTap
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            SocialShare.shareOptions('Wow! I\'ve fed my cat ${_score.amount} times!\nCan you beat me?'),//библиотека
        tooltip: 'Increment',
        child: const Icon(Icons.share),
      ),
    );
  }

  void _animate() async {
    for (int i = 0; i < 5; i++) {
      //чтобы анимация не пролетала слишгком быстро
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _current = 'assets/images/cat-food-hearts-icon-${i % 4}.png';
      });
    }
  }
}
