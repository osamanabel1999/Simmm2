import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'terms_o_fuse_model.dart';
export 'terms_o_fuse_model.dart';

class TermsOFuseWidget extends StatefulWidget {
  const TermsOFuseWidget({super.key});

  static String routeName = 'TermsOFuse';
  static String routePath = '/termsOFuse';

  @override
  State<TermsOFuseWidget> createState() => _TermsOFuseWidgetState();
}

class _TermsOFuseWidgetState extends State<TermsOFuseWidget> {
  late TermsOFuseModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TermsOFuseModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            'Privacy Policy',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              10.0, 0.0, 10.0, 0.0),
                          child: Text(
                            'Terms of Use for Simulator Station\n\nLast Updated: August 31, 2026\n\n\n1. Scope of Service\n\nSimulator Station is a third-party application designed to provide virtual cockpit interfaces, interactive checklists, voice-based features, simulator controls, and other tools intended to enhance the flight simulation experience.\n\nSimulator Station currently supports Microsoft Flight Simulator (MSFS), X-Plane 11, and X-Plane 12.\n\nThe application is independently developed and is not affiliated with, authorized by, sponsored by, or endorsed by Microsoft, Laminar Research, or any aircraft manufacturer, simulator developer, or other third-party company referenced within the application.\n\nAll trademarks, product names, and logos belong to their respective owners.\n\n\n2. Free Download & Premium Access\n\nSimulator Station is available as a free download.\n\nDownloading and installing the application does not provide free access to its simulator features or premium functionality.\n\nAccess to the application\'s simulator-specific features requires an applicable paid plan or purchase.\n\nSimulator Station may offer different access plans for each supported simulator, including:\n\n• Monthly Access\n• Yearly Access\n• Lifetime Access\n\nDepending on the offers available within the application, users may be able to purchase access to X-Plane features, Microsoft Flight Simulator features, or a combined offering covering supported features for both simulators.\n\nThe exact features included in each plan are displayed within the application and/or the applicable App Store purchase interface before purchase.\n\n\n3. Monthly & Yearly Subscriptions\n\nMonthly and yearly plans may be offered as auto-renewable subscriptions through Apple\'s In-App Purchase system.\n\nUnless cancelled by the user, an auto-renewable subscription will renew automatically at the end of each subscription period.\n\nThe applicable price and subscription period will be clearly displayed before the user confirms the purchase.\n\nUsers are responsible for managing and cancelling their subscriptions through their Apple account and the applicable App Store subscription settings.\n\nThe developer does not manually process recurring payments.\n\n\n4. Lifetime Access\n\nSimulator Station may offer a Lifetime Access option for supported simulator features.\n\nA Lifetime purchase is a one-time payment and does not automatically renew.\n\nLifetime Access provides access to the features associated with the specific Lifetime product purchased, subject to the limitations, compatibility requirements, and terms described within the application.\n\nLifetime Access does not guarantee that every future feature, simulator, aircraft, third-party service, or technology will remain available indefinitely.\n\nFeatures may be modified or discontinued when required by technical limitations, third-party changes, simulator changes, or other circumstances outside the developer\'s control.\n\n\n5. Pricing & Changes to Pricing\n\nThe developer reserves the right to establish, modify, increase, decrease, introduce, or discontinue prices for any plan or in-app purchase at any time.\n\nPrices may be changed without individually notifying every user.\n\nAny new or updated price will be displayed through the applicable App Store or purchase interface before a new purchase is completed.\n\nChanges to pricing will apply to future purchases and, where applicable, future subscription renewals in accordance with Apple\'s applicable rules and policies.\n\nA price change will not retroactively change the amount already paid for a completed purchase.\n\nFor auto-renewable subscriptions, Apple may apply additional requirements regarding price increases, including user notification or consent where required by Apple\'s policies.\n\n\n6. Advertising\n\nSimulator Station may display banner advertisements within the application.\n\nAdvertisements may remain visible even after purchasing a Monthly, Yearly, or Lifetime plan.\n\nPurchasing premium access does not automatically remove banner advertisements unless the specific purchase description explicitly states otherwise.\n\nAdvertising revenue may be used to support the development, maintenance, hosting, infrastructure, and third-party services required to operate and improve Simulator Station.\n\n\n7. \"For Simulation Use Only\" Disclaimer\n\nSimulator Station is strictly intended for entertainment and flight simulation purposes.\n\nThe application is designed to be used within supported flight simulator environments only.\n\nSimulator Station is NOT:\n\n• A real-world aircraft navigation system.\n\n• A certified flight training device.\n\n• A real-world aircraft control system.\n\n• A replacement for official aircraft documentation, operating manuals, checklists, or procedures.\n\n• Intended to provide real-world flight instructions or operational guidance.\n\nInformation, checklists, commands, data, or other content provided by Simulator Station must not be used for real-world aviation operations.\n\nThe developer assumes no responsibility for any real-world incident, accident, injury, loss, damage, or misuse resulting from using the application outside its intended simulation environment.\n\n\n8. Simulator Compatibility\n\nSimulator Station supports Microsoft Flight Simulator, X-Plane 11, and X-Plane 12.\n\nEach simulator has its own technical architecture, SDK, APIs, aircraft systems, limitations, and third-party integrations.\n\nAs a result, features may not operate identically across different simulators.\n\nA feature may be available on one simulator while being unavailable, restricted, or implemented differently on another.\n\nFeature availability may also depend on the specific aircraft, aircraft developer, simulator version, installed add-ons, plugins, simulator settings, network configuration, or other technical requirements.\n\n\n9. Microsoft Flight Simulator Support\n\nMicrosoft Flight Simulator support is part of the initial implementation of Simulator Station.\n\nBecause MSFS and its SDK impose certain technical limitations, some Simulator Station features may not be fully available or may behave differently within Microsoft Flight Simulator.\n\nSome features may work with certain aircraft but not with others.\n\nCertain aircraft may expose different systems, variables, events, or controls, which may limit the functionality available to Simulator Station.\n\nBecause this is an initial MSFS implementation, some features may be incomplete, limited, or temporarily unavailable.\n\nThe developer will make reasonable efforts to improve MSFS compatibility and expand supported functionality through future updates.\n\nHowever, the developer cannot guarantee that every Simulator Station feature will work with every aircraft, add-on, or future version of Microsoft Flight Simulator.\n\n\n10. X-Plane Support\n\nX-Plane functionality is also subject to the technical capabilities and limitations of X-Plane, its SDK, available interfaces, aircraft implementations, plugins, and third-party aircraft.\n\nSome features may work with certain X-Plane aircraft or versions but may be unavailable or behave differently with others.\n\nLikewise, certain features that are available in X-Plane may not be available in Microsoft Flight Simulator, and certain features available in Microsoft Flight Simulator may not be available in X-Plane.\n\nSimulator Station will attempt to provide the best possible functionality for each supported simulator, but feature parity between simulators is not guaranteed.\n\n\n11. Differences Between Simulators\n\nDue to differences between Microsoft Flight Simulator and X-Plane, Simulator Station may provide different functionality, controls, integrations, or features depending on the simulator being used.\n\nFor example:\n\n• A feature may be fully functional in X-Plane but limited in MSFS.\n\n• A feature may be available in MSFS but unavailable in X-Plane.\n\n• A feature may operate differently between the two simulators.\n\n• Certain aircraft may support functionality that other aircraft do not.\n\nThese differences are primarily caused by simulator SDK limitations, aircraft-specific implementations, third-party software, and technical restrictions.\n\nPurchasing access to one simulator does not guarantee identical functionality on another simulator.\n\n\n12. Feature Availability & Updates\n\nThe developer does not guarantee that every feature will be available at all times or on every supported simulator.\n\nFeatures may be:\n\n• Added or removed.\n• Modified or redesigned.\n• Improved or replaced.\n• Temporarily unavailable.\n• Limited by simulator or SDK restrictions.\n• Dependent on specific aircraft.\n• Dependent on third-party software or services.\n• Affected by simulator updates.\n• Affected by changes to third-party APIs or services.\n\nThe developer may modify, update, replace, suspend, or discontinue features when reasonably necessary to maintain, improve, or support the application.\n\n\n13. Hardware & Connection Requirements\n\nCertain Simulator Station features require communication between the user\'s mobile device and a computer running a supported flight simulator.\n\nDepending on the simulator and feature being used, the user may be required to:\n\n• Install required software on the computer.\n• Enable the appropriate simulator data or network output settings.\n• Configure the simulator correctly.\n• Configure any required companion software.\n• Ensure that the computer and mobile device are connected to the same local network.\n\nThe developer is not responsible for connection failures caused by the user\'s network, router, firewall, computer configuration, simulator configuration, mobile device, or third-party software.\n\n\n14. Voice Recognition\n\nSimulator Station may provide voice-based checklist and virtual co-pilot functionality.\n\nBy using voice recognition features, you acknowledge that voice commands may be processed through third-party artificial intelligence, speech recognition, or cloud-based services in order to provide the requested functionality.\n\nVoice recognition accuracy is not guaranteed.\n\nBackground noise, microphone quality, network connectivity, pronunciation, accents, simulator conditions, and third-party service availability may affect voice recognition accuracy.\n\nVoice recognition features are intended exclusively for simulation purposes and must not be used for real-world aviation operations.\n\n\n15. Third-Party Services\n\nCertain Simulator Station features may depend on third-party services, APIs, SDKs, artificial intelligence services, speech recognition services, advertising providers, network services, plugins, or other external technologies.\n\nThe availability, performance, and functionality of these third-party services are outside the direct control of the developer.\n\nThe developer does not guarantee uninterrupted availability of any third-party service and is not responsible for outages, changes, limitations, errors, restrictions, or discontinuation of third-party services.\n\n\n16. In-App Purchases\n\nAll purchases made through Simulator Station on the Apple App Store are processed through Apple\'s In-App Purchase system.\n\nPurchases may include:\n\n• Monthly subscriptions.\n• Yearly subscriptions.\n• Lifetime one-time purchases.\n\nPurchases may be offered separately for different simulator platforms or as combined access where such an option is available.\n\nThe exact price, duration, renewal terms, and included features will be displayed to the user before purchase.\n\nThe developer does not directly process or store the user\'s App Store payment information.\n\n\n17. Subscription Cancellation & Renewal\n\nMonthly and yearly subscriptions may automatically renew unless cancelled before the end of the current subscription period.\n\nUsers can manage or cancel subscriptions through their Apple account and App Store subscription settings.\n\nDeleting the application does not necessarily cancel an active subscription.\n\nCancellation takes effect according to Apple\'s applicable subscription and billing rules.\n\n\n18. Restore Purchases\n\nWhere supported, users may restore eligible previous purchases through the application\'s restore purchase functionality.\n\nRestored access is subject to successful verification through Apple\'s App Store purchase system.\n\nThe developer cannot manually restore purchases that cannot be verified through the applicable purchase system.\n\n\n19. Refunds\n\nPurchases made through the Apple App Store are subject to Apple\'s refund policies and applicable law.\n\nThe developer does not independently control Apple\'s refund decisions.\n\nUsers requesting a refund should use Apple\'s official refund process for App Store purchases.\n\n\n20. Intellectual Property\n\nSimulator Station, including its original software, interface designs, graphics, text, branding, and other original content, is protected by applicable intellectual property laws.\n\nUsers may not copy, reproduce, redistribute, reverse engineer, modify, sell, sublicense, or commercially exploit the application or its original content without appropriate authorization, except where expressly permitted by applicable law.\n\n\n21. Third-Party Trademarks\n\nMicrosoft Flight Simulator and MSFS are trademarks or products of Microsoft.\n\nX-Plane is a product of Laminar Research.\n\nSimulator Station is an independent third-party application and is not affiliated with, authorized by, sponsored by, or endorsed by Microsoft or Laminar Research.\n\nAll third-party trademarks, product names, logos, and intellectual property remain the property of their respective owners.\n\n\n22. Limitation of Liability\n\nTo the maximum extent permitted by applicable law, the developer shall not be liable for any direct, indirect, incidental, consequential, or other damages arising from the use of, inability to use, or misuse of Simulator Station.\n\nThis includes, but is not limited to:\n\n• Loss of data.\n• Simulator crashes.\n• Connection failures.\n• Hardware problems.\n• Software conflicts.\n• Network failures.\n• Third-party service interruptions.\n• Aircraft compatibility issues.\n• Simulator SDK limitations.\n• Problems caused by third-party aircraft, plugins, APIs, or software.\n\n\n23. User Responsibility\n\nThe user is responsible for ensuring that Simulator Station is used only for its intended purpose.\n\nUsers are responsible for maintaining their own devices, computers, networks, simulator installations, aircraft, plugins, and required third-party software.\n\nUsers should always follow the official documentation and requirements of the relevant flight simulator and any third-party software being used with Simulator Station.\n\n\n24. Changes to the Application\n\nSimulator Station may receive updates from time to time.\n\nUpdates may include:\n\n• Bug fixes.\n• Performance improvements.\n• New simulator support.\n• New features.\n• Changes to existing features.\n• Compatibility improvements.\n• Security and stability improvements.\n\nThe developer may modify the application at any time to improve functionality, maintain compatibility, address technical limitations, or comply with platform requirements.\n\n\n25. Changes to These Terms\n\nThe developer may update or modify these Terms of Use from time to time.\n\nUpdated terms may be made available within the application or through the applicable distribution platform.\n\nContinued use of Simulator Station after updated terms become available constitutes acceptance of the updated terms to the extent permitted by applicable law.\n\n\n26. Acceptance of These Terms\n\nBy downloading, installing, accessing, or using Simulator Station, you acknowledge that you have read, understood, and agreed to these Terms of Use.\n\nIf you do not agree with these terms, you should discontinue use of the application.\n\n\n27. Contact\n\nIf you have questions, concerns, or requests regarding Simulator Station or these Terms of Use, you may contact the developer through the contact information provided within the application or through its official support channels.',
                            textAlign: TextAlign.start,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
