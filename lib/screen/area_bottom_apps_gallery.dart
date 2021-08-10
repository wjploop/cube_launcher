import 'dart:ui';

import 'package:cube_launcher/components/app_state.dart';
import 'package:cube_launcher/data/AppInfo.dart';
import 'package:cube_launcher/data/Repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AppGalley extends StatefulWidget {
  const AppGalley({Key? key}) : super(key: key);

  @override
  _AppGalleyState createState() => _AppGalleyState();
}

class _AppGalleyState extends State<AppGalley> {

  @override
  void initState() {
    super.initState();
    loading();
  }



   void loading() async{
    await Repo.init();
    context.read<AppData>().loaded();

  }
  @override
  Widget build(BuildContext context) {

    return Consumer<AppData>(builder: (context, appdata, child) {
      if(!appdata.hadLoad) {
        return Container(child: Center(child: Text("Loading..."),),);
      }
      return GridView.count(
          crossAxisCount: 5,
          childAspectRatio: 0.6,
          padding: EdgeInsets.all(8),
          mainAxisSpacing: 18,
          crossAxisSpacing: 10,
          children: Repo.apps.map((e) => GalleryItem(app: e)).toList());
    },);
  }
}



class GalleryItem extends StatelessWidget {
  final AppInfo app;

  const GalleryItem({Key? key, required this.app}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var iconSize = screenSize.width/5 - 26;
    return LongPressDraggable(
      data: app,
      feedback:  ClipOval(
        child: Image.memory(
          app.icon,
          width: iconSize,
          height: iconSize,
        ),
      ),

      child: Container(
        height: iconSize*3,
        width: iconSize,
        child: Center(
          child: Column(
            children: [
              Container(
                child: ClipOval(
                  child: Image.memory(
                    app.icon,
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                child: Text(
                  "${app.name}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,

                  style: Theme.of(context).textTheme.caption?.copyWith(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
