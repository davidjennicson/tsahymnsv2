import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/settings_modal.dart';

class DoctrineScreen extends StatefulWidget {
  const DoctrineScreen({super.key});

  @override
  State<DoctrineScreen> createState() => _DoctrineScreenState();
}

class _DoctrineScreenState extends State<DoctrineScreen> {
  int _selectedSegment = 0;

  void _showSettingsModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => const SettingsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final backgroundColor = appState.getBackgroundColor();
        final textColor = appState.getTextColor();
        final secondaryTextColor = appState.getSecondaryTextColor();
        final cardColor = appState.getCardColor();
        final double fontSize = appState.fontSize;

        return CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: backgroundColor,
            border: null,
            middle: Text(
              'Doctrine',
              style: TextStyle(
                fontFamily: "Inter",
                fontVariations: [
                  FontVariation('wght', 700),
                ],
                fontSize: 18,
                color: textColor,
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Icon(
                CupertinoIcons.chevron_left,
                color: textColor,
                size: 24,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: appState.toggleTheme,
                  child: Icon(
                    appState.isDarkMode ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                    color: textColor,
                    size: 22,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _showSettingsModal(context),
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    color: textColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Segmented Control
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: secondaryTextColor.withOpacity(0.2),
                          ),
                        ),
                        child: CupertinoSlidingSegmentedControl<int>(
                          groupValue: _selectedSegment,
                          onValueChanged: (value) {
                            setState(() {
                              _selectedSegment = value ?? 0;
                            });
                          },
                          children: {
                            0: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'English',
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontVariations: [
                                    FontVariation('wght', 600),
                                  ],
                                  color: _selectedSegment == 0 ? CupertinoColors.destructiveRed : textColor,
                                ),
                              ),
                            ),
                            1: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'தமிழ்',
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontVariations: [
                                    FontVariation('wght', 600),
                                  ],
                                  color: _selectedSegment == 1 ? CupertinoColors.destructiveRed : textColor,
                                ),
                              ),
                            ),
                          },
                        ),
                      ),
                    ),
                  ),
                  // Doctrine Content
                  _selectedSegment == 0
                      ? _buildEnglishDoctrine(textColor, fontSize)
                      : _buildTamilDoctrine(textColor, fontSize),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnglishDoctrine(Color textColor, double fontSize) {
    final List<String> doctrines = [
      'We Believe that the Scriptures of the Old and New Testaments were given by the inspiration of God and that they only constitute the Divine rule of Christian faith and practice.',
      'We Believe that there is only one God, who is infinitely perfect, the Creator, Preserver, and Governor of all things, and who is the only proper object of religious worship.',
      'We Believe that there are three persons in the Godhead - the Father, the Son, and the Holy Ghost, undivided in essence and co-equal in power and glory.',
      'We Believe that in the person of Jesus Christ the Divine and human natures are united so that He is truly and properly God and truly and properly man.',
      'We Believe that our first parents were created in a state of innocency, but by their disobedience, they lost their purity and happiness, and that in consequence of their fall, all men have become sinners, totally depraved, and as such are justly exposed to the wrath of God.',
      'We Believe that the Lord Jesus Christ has by His suffering and death made an atonement for the whole world so that whosoever will may be saved.',
      'We Believe that repentance toward God, faith in our Lord Jesus Christ, and regeneration by the Holy Spirit are necessary for salvation.',
      'We Believe that we are justified by grace through faith in our Lord Jesus Christ and that he that believeth hath the witness in himself.',
      'We Believe that continuance in a state of salvation depends upon continued obedient faith in Christ.',
      'We Believe that it is the privilege of all believers to be wholly sanctified and that their whole spirit, soul, and body may be preserved blameless unto the coming of our Lord Jesus Christ.',
      'We Believe in the immortality of the soul, the resurrection of the body, the general judgment at the end of the world, the eternal happiness of the righteous, and the endless punishment of the wicked.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var doctrine in doctrines) ...[
          _buildDoctrinePoint(textColor, fontSize, doctrine),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTamilDoctrine(Color textColor, double fontSize) {
    final List<String> doctrines = [
      'பழைய ஏற்பாடும், புதிய ஏற்பாடும் அடங்கிய வேதாகமமானது தேவனுடைய ஏவுதலினால் அருளப்பட்டதென்றும், கிறிஸ்தவ விசுவாசமும், கிரியையுமாகிய தெய்வீகச் சட்டம் அதில் அடங்கியிருக்கிறதென்றும் விசுவாசிக்கிறோம்.',
      'எல்லாவற்றிற்கும் சிருஷ்டிகரும், பாதுகாவலரும், ஆளுகிறவரும், சர்வபூரணருமான ஒரே தேவன் உண்டென்றும், அவரே மார்க்கீக வணக்கத்திற்குரியவரென்றும் விசுவாசிக்கிறோம்.',
      'தத்துவத்தில் பிரியாதவர்களும், வல்லமையிலும், மகிமையிலும், சமமானவர்களுமான பிதா, குமாரன், பரிசுத்தாவியானவராகிய மூவர் தேவத்துவத்தில் உண்டென்றும் விசுவாசிக்கிறோம்.',
      'கர்த்தராகிய கிறிஸ்துவில் தெய்வீகத் தன்மையும், மனிதத்தன்மையும் பொருந்தியிருக்கின்றனவென்றும், அதனால் அவர் மெய்யாகவே தேவனாகவும், மெய்யாகவே மனிதனாகவும், இருக்கிறாரென்றும் விசுவாசிக்கிறோம்.',
      'நமது ஆதிப்பெற்றோர் நிர்மலமான நிலையில் சிருஷ்டிக்கப்பட்டார்களென்றும், ஆனால் அவர்களுடைய கீழ்ப்படியாமையால் தங்களுடைய தூய்மையையும், பாக்கியத்தையும் இழந்தார்கள் என்றும், அதன் பலனாய் எல்லா மனிதரும் பாவிகளாயும், முற்றிலும் சீரழிந்தவர்களாயும் ஆனார்களென்றும், ஆகையால் தேவனுடைய நியாயமான கோபாக்கினைக்குள்ளானார்களென்றும் விசுவாசிக்கிறோம்.',
      'கர்த்தராகிய இயேசுகிறிஸ்து, விருப்பமுள்ளவர்களெவர்களோ அவர்கள் அனைவரும் இரட்சிக்கப்படும் பொருட்டு, தம்முடைய பாடு மரணத்தால் உலகம் முழுவதற்கும் வேண்டிய பிராயச்சித்தப் பலியானாரென்றும் விசுவாசிக்கிறோம்.',
      'தேவனுக்கு முன் மனஸ்தாபமும் கர்த்தராகிய இயேசு கிறிஸ்துவில் விசுவாசமும், பரிசுத்தாவியானவராலுண்டாகும் மறுபிறப்பும் இரட்சிப்புக்கு அவசியமென விசுவாசிக்கிறோம்.',
      'கர்த்தராகிய கிறிஸ்து இயேசுவிலுள்ள விசுவாசத்தின் மூலம் அவருடைய கிருபையினால் நீதிமான்களாக்கப்படுகிறோம் என்றும், அவரில் விசுவாசிக்கிறவன் தன்னிலே அந்த சாட்சியை உடையவனாய் இருக்கிறாரென்றும் விசுவASICிக்கிறோம்.',
      'இரட்சிப்பில் நிலைத்திருப்பது கிறிஸ்துவில் உள்ள தொடர்பான விசுவாசத்திலும், கீழ்ப்படிதலிலும், சார்ந்திருக்கிறதென்று விசுவாசிக்கிறோம்.',
      'முற்றிலும் சுத்திகரிக்கப்பட்டிருத்தல், விசுவாசிகள் யாவருடைய சிலாக்கியமாயிருக்கிறதென்றும், அவர்களுடைய ஆவி, ஆத்துமா, சரீரம் முழுவதும் கர்த்தராகிய இயேசுகிறிஸ்துவின் வருகை மட்டும் குற்றமற்றதாய்க் காக்கப்படக் கூடுமென்றும் விசுவாசிக்கிறோம்.',
      'ஆத்துமாவின் அழியாமையிலும், சரீரத்தின் உயிர்த்தெழுதலிலும், உலக முடிவிலுண்டாகும் பொதுவான நியாயத் தீர்ப்பிலும், நீதிமான்களுடைய நித்திய ஆனந்தத்திலும் துன்மார்க்கருடைய நித்திய ஆக்கினையிலும் நாம் விசுவாசிக்கிறோம்.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var doctrine in doctrines) ...[
          _buildDoctrinePoint(textColor, fontSize, doctrine, isTamil: true),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDoctrinePoint(Color textColor, double fontSize, String text, {bool isTamil = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•   ',
          style: TextStyle(
            fontFamily: "Source Serif 4",
            fontSize: fontSize,
            color: textColor,
            height: 1.6,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: isTamil ? "NotoSansTamil" : "SourceSerif4",
              fontSize: fontSize,
              height: 1.6,
              color: textColor,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}