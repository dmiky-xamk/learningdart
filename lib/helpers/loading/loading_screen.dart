import 'dart:async';
import 'loading_screen_controller.dart';
import 'package:flutter/material.dart';

// ! Tämän avulla hallitaan koko ohjelman latauksia yhdessä paikassa

class LoadingScreen {
  // * Singleton
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  // * Luodaan classiin controller jotta piilottaessa voidaan sulkea(?)
  LoadingScreenController? controller;

  // * Näyttää overlayn
  void show({
    required BuildContext context,
    required String text,
  }) {
    // * Jos controllerin tekstiä voidaan päivittää -> se on jo olemassa joten palataan
    // falsella ei tehdä mitään mutta se lyhentää koodia kun update voi palauttaa boolin niin se toimii
    if (controller?.update(text) ?? false) {
      return;
    } else {
      // * Muuten luodaan uusi controller
      controller = _showOverlay(
        context: context,
        text: text,
      );
    }
  }

  // * Piilottaa LoadingScreenin
  void hide() {
    controller?.close();
    controller = null;
  }

  // * Funktio joka näyttää LoadingScreenin ja palauttaa LoadingScreenControllerin
  // * jonka avulla latausruutua pystyy hallitsemaan
  LoadingScreenController _showOverlay({
    required BuildContext context,
    required String text,
  }) {
    // * Stream jonka avulla latausruudun sisältöä voidaan päivittää
    final _text = StreamController<String>();
    // * Lisätään teksti streamiin
    _text.add(text);

    // * Palauttaa staten jota tarvitaan oman overlayn näyttämiseen
    final state = Overlay.of(context);

    // * Overlayta varten tarvitaan tietoa kuinka paljon ruudulla on vapaata tilaa
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // * Luodaan varsinaisesti overlay entry
    final overlay = OverlayEntry(
      builder: (context) {
        // * OverlayEntryä varten pitää olla parent jottei se näytä ihan paskalta (sillä ei ole parentia)
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                // * Vie maksimissaan 80% ruudulla olevasta tilasta (margin)
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                // * Vie vähintään 50% ruudulla olevasta tilasta (margin)
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // * Jotta voidaan scrollata jos tekstiä on liikaa (muuten ei scroll)
                child: SingleChildScrollView(
                  child: Column(
                    // * Vie tilaa niin vähän kuin mahollista (muuten vie kaiken tilan)
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // * Antaa marginia 10 unitia
                      const SizedBox(height: 10),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      StreamBuilder(
                        // * Käytetään stream controllerin tekstiä stream builderissa
                        stream: _text.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Container();
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // * Yllä luotiin overlay, nyt huolehditaan sen näyttämisestä
    state?.insert(overlay);

    // * Palautetaan controller jonka avulla kutsuja voi sulkea ja päivittää latausruutua
    return LoadingScreenController(
      close: () {
        _text.close();
        overlay.remove();
        return true;
      },
      update: (text) {
        _text.add(text);
        return true;
      },
    );
  }
}
