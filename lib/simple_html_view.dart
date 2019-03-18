import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class SimpleHtmlView extends StatelessWidget {
  final String data;
  final EdgeInsetsGeometry padding;
  final String baseURL;
  final Function onLaunchFail;

  SimpleHtmlView({this.data, this.padding = const EdgeInsets.all(5.0), this.baseURL, this.onLaunchFail});

  @override
  Widget build(BuildContext context) {
    return new Html(
      data: this.data,
      onLinkTap: (url) async {
        final exp = RegExp('/asset/.');
        if (exp.hasMatch(url)) url = 'http://pottersschool.org' + url;
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
    );
  }
}

// replace extra or unreadable html tags with something simpler
String simplifyHtml(String html) {
  if (html != null ) return html
    .replaceAll(new RegExp('(<br/>)'), '\n')
    .replaceAll(new RegExp('<tr>'), '<h1>')
    .replaceAll(new RegExp('</tr>'), '</h1>\n')
    .replaceAll(new RegExp('</strong>'), ':')
    .replaceAll(new RegExp('((<div|<span)[^>]*>)+'), '</p><p>')
    .replaceAll(new RegExp('((</div|</span)[^>]*>)+'), '</p><p>')
    ;
  return '';
}
