import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:teciza_hr/utils/base64_decode.dart';
import 'package:teciza_hr/utils/preferences.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});

  Future<Map<String, dynamic>> _employeeInfo(BuildContext context) async {
    var empData = await Preferences.getData<Map<String, dynamic>>("emp_info");
    return empData ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([_employeeInfo(context)]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final empData = snapshot.data![0];

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 35),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.red[200],
                  child: empData['image_base64']?.isNotEmpty ?? false
                      ? ClipOval(
                          child: Image.memory(
                            Base64ToImage.base64Decoder(empData['image_base64'])!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(height: 10),
                Text(
                  empData['employee_name'] ?? 'Unknown',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  empData['designation'] ?? 'Unknown',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                buildExpansionTile(
                  context,
                  title: "Employee Details",
                  icon: FluentSystemIcons.ic_fluent_person_accounts_regular,
                  content: {
                    "Full Name": empData['employee_name'] ?? '-',
                    "Employee Number": empData['name'] ?? '-',
                    "Gender": empData['gender'] ?? '-',
                    "Date of Birth": empData['date_of_birth'] ?? '-',
                    "Date of Joining": empData['date_of_joining'] ?? '-',
                    "Blood Group": empData['blood_group'] ?? '-',
                  },
                ),
                buildExpansionTile(
                  context,
                  title: "Company Information",
                  icon: FluentSystemIcons.ic_fluent_building_regular,
                  content: {
                    "Company": empData['company'] ?? '-',
                    "Department": empData['department'] ?? '-',
                    "Designation": empData['designation'] ?? '-',
                    "Branch": empData['branch'] ?? '-',
                    "Grade": empData['grade'] ?? '-',
                    "Reports to": empData['reports_to_name'] ?? '-',
                    "Employment Type": empData['employment_type'] ?? '-',
                  },
                ),
                buildExpansionTile(
                  context,
                  title: "Contact Information",
                  icon: FluentSystemIcons.ic_fluent_contact_card_regular,
                  content: {
                    "Mobile": empData['cell_number'] ?? '-',
                    "Personal Email": empData['personal_email'] ?? '-',
                    "Company Email": empData['company_email'] ?? '-',
                  },
                ),
                buildExpansionTile(
                  context,
                  title: "Salary Information",
                  icon: FluentSystemIcons.ic_fluent_currency_regular,
                  content: {
                    "Cost to Company (CTC)": empData['ctc']?.toString() ?? '-',
                    "Payroll Cost Center": empData['payroll_cost_center'] ?? '-',
                    "Salary Mode": empData['salary_mode'] ?? '-',
                    "Bank Name": empData['bank_name'] ?? '-',
                    "Bank A/C No.": empData['bank_ac_no'] ?? '-',
                    "IBAN": empData['iban'] ?? '-',
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildExpansionTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Map<String, String> content,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          leading: Icon(icon, color: Colors.black54),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          onTap: () {
            // Modal sheet for detailed view (half-screen and scrollable)
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: content.entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 6,
                                    child: Text(
                                      entry.value,
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
