import 'package:expense_tracker/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key); // ✅ correct
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureShow=true;

  final TextEditingController emailController= TextEditingController();
  final TextEditingController passwordController= TextEditingController();



@override
void disose(){
  emailController.dispose();
  passwordController.dispose();
}

Future<void> signInWithEmailAndPassword()async {
  try{
    FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());
    Navigator.pushNamedAndRemoveUntil(context, "HomeScreen", (route) => false);
  }
  on FirebaseAuthException catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message?? "Login Failed")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/login.png"),fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent ,
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(left: 50,top: 150),
              child: Text("Welcome\nBack",style: TextStyle(color: Colors.white,fontSize:33, ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.5,right: 35,left: 35),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.alternate_email_outlined),
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          hintText:"  Email",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                      ),
                    ),
                    SizedBox(height: 30,),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscureShow,
                      decoration: InputDecoration(
                          suffixIcon: InkWell(
                              onTap: (){
                                setState(() {
                                  _obscureShow =_obscureShow;
                                });
                              },
                              child: Icon(Icons.remove_red_eye,)),
                          filled: true,
                          fillColor:Colors.grey.shade100,
                          hintText:"  Password",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("sign In", style: TextStyle
                          (fontSize: 27,fontWeight:FontWeight.w700),
                        ),

                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Color(0xff4c505b),
                          child: IconButton(
                            color: Colors.white,
                            onPressed: () async {
                            await signInWithEmailAndPassword();
                            },
                            icon: Icon(Icons.arrow_forward),),
                        ),
                      ],
                    ),
                    SizedBox(height: 25,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        TextButton(onPressed: (){
                          Navigator.pushNamed(context, "register");
                        }, child: Text
                          ("sign Up",style: TextStyle
                          (fontSize: 18,color:Color(0xff4c505b),fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline),)),

                        TextButton(onPressed: (){}, child: Text
                          ("Password Forget",style: TextStyle
                          (fontSize: 18,color:Color(0xff4c505b),fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline),))
                      ],
                    ),
                  ],

                ),

              ),
            ),
          ],
        ),
      ),


    );
  }
}
