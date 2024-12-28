import 'package:befriend/providers/edit_profile_provider.dart';
import 'package:befriend/utilities/app_localizations.dart';
import 'package:befriend/utilities/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => EditProfileProvider(),
        builder: (BuildContext context, Widget? child) {
          return Consumer<EditProfileProvider>(builder: (BuildContext context,
              EditProfileProvider provider, Widget? child) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.translate(context,
                    key: "epp_edit", defaultString: "Edit Profile")),
              ),
              body: FutureBuilder(
                  future: provider.initWidgetState(),
                  builder: (BuildContext context, AsyncSnapshot<String> data) {
                    if (!data.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: provider.avatar(),
                          ),
                          const SizedBox(height: 8.0),
                          provider.isEditLoading || provider.isRemoveLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                        onPressed: () =>
                                            provider.changeAvatar(context),
                                        child: Text(AppLocalizations.translate(
                                            context,
                                            key: 'epp_avatar',
                                            defaultString: 'Edit avatar'))),
                                    const SizedBox(height: 8.0),
                                    TextButton(
                                        onPressed: () =>
                                            provider.removeAvatar(context),
                                        child: Text(AppLocalizations.translate(
                                            context,
                                            key: 'epp_remove',
                                            defaultString: 'Remove avatar'))),
                                  ],
                                ),
                          const SizedBox(height: 16.0),
                          Form(
                            key: provider.usernameKey,
                            child: TextFormField(
                              initialValue: provider.oldUsername,
                              onSaved: provider.onUsernameSaved,
                              validator: (String? value) =>
                                  provider.usernameValidator(value, context),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.translate(context,
                                    key: 'epp_username',
                                    defaultString: 'Username'),
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Form(
                            key: provider.bioKey,
                            child: TextFormField(
                              initialValue: provider.oldBio,
                              onSaved: provider.onBioSaved,
                              validator: (String? value) =>
                                  provider.bioValidator(value, context),
                              maxLength: Validators.maxBioLength,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.translate(context,
                                    key: 'epp_bio', defaultString: 'Bio'),
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32.0),
                          Container(
                              width: double.infinity,
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                  onPressed: () =>
                                      provider.saveProfile(context),
                                  child: provider.isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : const Text('Save'))),
                        ],
                      ),
                    );
                  }),
            );
          });
        });
  }
}
