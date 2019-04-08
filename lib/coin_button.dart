import 'package:flutter/material.dart';
import 'package:study_anyplace/message.dart';

class CoinButton extends StatefulWidget {

  final Message message;

  CoinButton({Key key, this.message}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CoinButtonState();
  }
}

class CoinButtonState extends State<CoinButton> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = new Tween(
      begin: -1.0,
      end: 1.0,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(0.0),
      icon: AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget child) {
          final Matrix4 transform = new Matrix4.identity()
            ..scale(_animation.value, 1.0);
          return new Transform(
            transform: transform,
            alignment: FractionalOffset.center,
            child: child,
          );
        },
        child: CircleAvatar(
          radius: 24.0,
          backgroundColor: widget.message.isRead ? Colors.green : Colors.red,
          child: Icon(
            widget.message.isRead ? Icons.drafts : Icons.markunread,
            color: Colors.grey[850],
            size: 30.0,
          ),
        ),
      ),
      onPressed: () {
        setState(() {
          widget.message.toggleRead();
            if (_controller.isCompleted || _controller.velocity > 0)
              _controller.reverse();
            else
              _controller.forward();
        });
      },
    );
  }
}