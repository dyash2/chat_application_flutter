import 'package:flutter/material.dart';

class CustomUsertile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const CustomUsertile({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          spacing: 10,
          children: [
            //icon
            Icon(Icons.person,color: Colors.white,),

            //user name
            Text(text,style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
          ],
        ),
      ),
    );
  }
}
